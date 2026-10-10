{
  config,
  pkgs,
  lib,
  hostName,
  self,
  ssh,
  ...
}:
{
  networking.hostName = "usb-remote";
  nixpkgs.hostPlatform = "x86_64-linux";
  services.userborn.enable = true;

  # Bootloader configured for portable USB (do not alter host motherboard NVRAM)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;

  # Automatic reboot after 10s on kernel panic (avoids indefinite freeze on headless machines)
  boot.kernelParams = [ "panic=10" ];

  # Generic x86_64 storage and USB hardware support in initrd
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "nvme"
    "uas"
    "rtsx_pci_sdmmc"
  ];

  # Lightweight Wi-Fi daemon with built-in DHCP (+2.5MB), managed interactively via iwctl
  networking.wireless.iwd = {
    enable = true;
    settings.Settings.EnableNetworkConfiguration = true;
  };

  # Impermanence: state persisted explicitly on /persist (/nix/persist)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log/journal"
      "/var/lib/tailscale"
      "/var/lib/iwd"
      "/etc/ssh"
    ];
  };

  # Compatibility symlink for any legacy references to /nix/persist
  systemd.tmpfiles.rules = [
    "L+ /nix/persist - - - - /persist"
  ];

  # Journald persistent logging with structured RFC 42 settings
  services.journald.settings.Journal = {
    Storage = "persistent";
    MaxRetentionSec = "30day";
    SystemMaxUse = "200M";
    SystemMaxFileSize = "50M";
  };

  # OpenSSH server with key-only authentication
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Headless power policy: prevent laptop suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEbJzrHvhXgm5jvL4clxiKcGSWt076D+kPZt+a+ZcRQ Malix - Alix Brunet"
  ];

  vaultix.secrets.malix_password = {
    file = ./password.age;
  };
  vaultix.beforeUserborn = [ "malix_password" ];

  users.users.malix = {
    isNormalUser = true;
    hashedPasswordFile = config.vaultix.secrets.malix_password.path;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  security.sudo.wheelNeedsPassword = false;

  # Tailscale unattended remote access
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--hostname=usb-remote"
      "--ssh"
    ];
    authKeyFile = lib.mkIf (
      config.vaultix.secrets ? tailscale_authkey
    ) config.vaultix.secrets.tailscale_authkey.path;
  };

  # Vaultix: decrypt secrets using usb-remote's SSH host key
  vaultix.settings.hostPubkey = ssh.hosts.usb-remote;

  # Storage constraints: auto-deduplication, reactive GC via min-free/max-free, zram swap
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      # Reactive on-demand GC: only triggers during nix commands when space is low
      min-free = 256 * 1024 * 1024; # 256 MiB: trigger GC if free space drops below this
      max-free = 1024 * 1024 * 1024; # 1 GiB: delete dead paths until 1 GiB is free
    };

    distributedBuilds = true;
    buildMachines = [
      {
        inherit hostName; # "malix-legion-nixos" via specialArgs & Tailscale MagicDNS
        sshUser = "nix-builder";
        sshKey = "/persist/etc/ssh/ssh_host_ed25519_key";
        protocol = "ssh-ng";
        systems = [ self.nixosConfigurations.${hostName}.config.nixpkgs.hostPlatform.system ];
        maxJobs = 4;
        speedFactor = 4;
        supportedFeatures = [
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  zramSwap.enable = true;

  # Lightweight nh with stripped binary (drops ~76MB Haskell nom), retaining last 3 generations
  programs.nh = {
    enable = true;
    package = pkgs.nh-unwrapped;
    clean = {
      enable = true;
      extraArgs = "--keep 3";
      dates = "weekly";
    };
  };

  # Universal cross-shell SSH logging to systemd journal (interactive and remote command tasks)
  environment.shellInit = ''
    if [ -n "$SSH_CONNECTION" ] && [ -z "$ALREADY_LOGGED" ]; then
      case "$BASH_EXECUTION_STRING" in
        *nix-daemon*|*nix-store*|*sftp-server*|*scp*) ;;
        *)
          export ALREADY_LOGGED=1
          exec > >(tee >(systemd-cat -t "$USER")) 2>&1
          ;;
      esac
    fi
  '';

  # TTY1 Display Kiosk: btop + live journalctl stream in dynamically tiled tmux
  systemd.services."autovt@tty1".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services.display-kiosk = {
    description = "TTY1 btop and journal monitor kiosk";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    conflicts = [
      "getty@tty1.service"
      "autovt@tty1.service"
    ];
    serviceConfig = {
      StandardInput = "tty";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
      Restart = "always";
      RestartSec = "2s";
      ExecStart = pkgs.writeShellScript "display-kiosk" ''
        ${pkgs.tmux}/bin/tmux kill-session -t kiosk 2>/dev/null || true
        exec ${pkgs.tmux}/bin/tmux new-session -s kiosk -d "${pkgs.btop}/bin/btop" \; \
          set-option -g status off \; \
          set-option -g pane-border-status off \; \
          split-window -t kiosk "${pkgs.systemd}/bin/journalctl -f -o short-iso -n 50" \; \
          set-hook -g window-resized 'if-shell -F "#{e|>=:#{window_width},#{e|*:#{window_height},2}}" "select-layout even-horizontal" "select-layout even-vertical"' \; \
          if-shell -F "#{e|>=:#{window_width},#{e|*:#{window_height},2}}" "select-layout -t kiosk even-horizontal" "select-layout -t kiosk even-vertical" \; \
          attach-session -t kiosk
      '';
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t kiosk";
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    tmux
  ];

  system.stateVersion = "26.05";
}
