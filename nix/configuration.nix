{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  declarative-flatpak,
  mcp-nixos,
  fh,
  ...
}:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://install.determinate.systems" ];
    extra-trusted-public-keys = [ "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=" ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    # initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/UUID-OF-SDA2"; # TODO: see https://wiki.nixos.org/wiki/Full_Disk_Encryption#Enter_password_on_Boot to continue setup
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium ; also see https://github.com/NixOS/nixpkgs/issues/291051

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "fr_CH.UTF-8/UTF-8"
    "fr_FR.UTF-8/UTF-8"
  ];

  console.keyMap = "fr";

  services = {

    # DEPRECATED IN 25.11
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "fr";
        variant = "";
      };
    };

    /*
      # TO REPLACE XSERVER IN 25.11
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    */

    printing.enable = true;

    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
      packages = [
        "flathub:app/org.vinegarhq.Sober//stable"
      ];
      overrides = {
        "org.vinegarhq.Sober" = {
          filesystems = [
            "xdg-run/app/com.discordapp.Discord:create"
            "xdg-run/discord-ipc-0"
          ];
        };
      };

      # Workaround for unsupported overrides (see https://github.com/in-a-dil-emma/declarative-flatpak/issues/42)
      preSwitchCommand = ''
        flatpak override --user --device=input org.vinegarhq.Sober
      '';
    };

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
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
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.noto
  ];

  security.rtkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  /*
    # Not needed since declarative-flatpak and nix-flatpak handles this
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  */

  environment.systemPackages = with pkgs; [
    ghostty

    helix

    wget
    git
    fastfetch
    wl-clipboard-rs
    # clipboard-jh # broken for Wayland, see https://github.com/Slackadays/Clipboard/issues/171

    nixd
    nixfmt-rfc-style
    fh.packages.${pkgs.system}.default
    mcp-nixos.packages.${pkgs.system}.default

    mission-center
    audacity

    google-chrome

    cloudflare-warp
    protonvpn-gui
  ];

  virtualisation.waydroid.enable = true;

  users.users.malix = {
    isNormalUser = true;
    description = "Malix";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      gh
      vesktop
      pkgs-unstable.zed-editor.fhs
      vscode.fhs
      gitkraken
    ];
  };

  system.rebuild.enableNg = true; # default in 25.11

  system.stateVersion = "24.11"; # NEVER MUTATE
}
