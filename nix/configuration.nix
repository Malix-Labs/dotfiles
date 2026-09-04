{
  config,
  lib,

  pkgs,

  nixpkgs-chosen,
  nixpkgs-unstable,
  nixpkgs-stable,

  username,
  hostName,
  dotfilesDirectory,
  ssh,

  cachyos-kernel,
  nixConfig,

  ...
}:
{
  imports = [
    ./gaming.nix
    ./users/malix/secrets.nix
  ];

  nix = {
    daemonCPUSchedPolicy = "batch";

    registry = {
      nixpkgs = lib.mkForce { flake = nixpkgs-chosen; }; # Override determinate
      nixpkgs-stable.flake = nixpkgs-stable;
      nixpkgs-unstable.flake = nixpkgs-unstable;
      nixpkgs-stable-latest.to = {
        type = "tarball";
        url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
      };
      nixpkgs-unstable-latest.to = {
        type = "tarball";
        url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
      };
      # templates # gets shortcutted by determinate nix ; see https://github.com/DeterminateSystems/nix-src/issues/339
    };
    settings = nixConfig;
  };

  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 20;
    IOWeight = 20;
    MemoryHigh = "80%";
  };

  boot = {
    kernelPackages =
      cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages-cachyos-latest-lto-x86_64-v3;
    loader = {
      systemd-boot = {
        enable = lib.mkForce false; # replaced by lanzaboote
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 8; # maximum by systemd-pcrlock (see https://github.com/nix-community/lanzaboote/blob/b9e331d75d4618c7073ea08ff30fddf9a7d2fb08/nix/modules/lanzaboote.nix#L429-L438)

      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
        includeFirmwareBuiltinKeys = true;
      };

      measuredBoot = {
        enable = true;

        # only stable ones
        pcrs = [
          0
          4
          7
        ];

        autoCryptenroll = {
          enable = true;
          device = "/dev/nvme0n1p2";
          autoReboot = true;
        };
      };

      bootCounting.initialTries = 3;
    };
    tmp.useTmpfs = true;
    kernel.sysctl."vm.swappiness" = 100;
    supportedFilesystems.exfat = true;
  };

  zramSwap.enable = true;

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium ; also see https://github.com/NixOS/nixpkgs/issues/291051

  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = "fr_CH.UTF-8";
    extraLocaleSettings.LANGUAGE = "en:C:fr";
  };

  console.keyMap = "fr";

  services = {

    xserver.xkb.layout = "fr";
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    switcherooControl.enable = true; # hotfix nixos-hardware https://github.com/NixOS/nixos-hardware/pull/2004

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      raopOpenFirewall = true;
      extraConfig.pipewire = {
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";
            }
          ];
        };
      };
    };

    flatpak.enable = true;

    ratbagd.enable = true;
    hardware.openrgb.enable = true;

    cloudflare-warp.enable = true;
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
    };

    userborn.enable = true;
  };

  hardware.bluetooth.enable = true;

  programs = {
    git.enable = true;
    nix-ld.enable = true;
    partition-manager.enable = true;
    kdeconnect.enable = true;
    bandwhich.enable = true;
    command-not-found.enable = false;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    noto-fonts-color-emoji
    nerd-fonts.fira-code
  ];

  security.rtkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      sbctl

      ghostty

      helix

      wget
      fastfetch
      wl-clipboard-rs
      # clipboard-jh # broken for Wayland, see https://github.com/Slackadays/Clipboard/issues/171

      nixd
      nil
      nixfmt
      flake-edit
      flake-du
      fh
      mcp-nixos

      piper

      proton-vpn
    ];

    etc.nixos.source = "${config.users.users.${username}.home}/${dotfilesDirectory}";
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other. See https://wiki.nixos.org/wiki/Podman
    };
    waydroid.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = ./home.nix;
    backupFileExtension = "bak";
  };

  vaultix.settings.hostPubkey = ssh.host;

  users.users.${username} = {
    isNormalUser = true;
    description = "Malix";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
  };

  system.stateVersion = "24.11"; # NEVER MUTATE
}
