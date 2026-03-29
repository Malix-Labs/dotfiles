{
  config,
  lib,
  hostName,
  pkgs,
  pkgs-unstable,

  nixpkgs-chosen,
  nixpkgs-unstable,
  nixpkgs-stable,

  cachyos-kernel,

  mcp-nixos,
  fh,
  ...
}:
{
  imports = [
    ./gaming.nix
  ];

  nix = {
    registry = {
      nixpkgs = lib.mkForce { flake = nixpkgs-chosen; }; # Override determinate
      nixpkgs-stable.flake = nixpkgs-stable;
      nixpkgs-unstable.flake = nixpkgs-unstable;
      nixpkgs-stable-latest.to = {
        type = "tarball";
        url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
      };
      nixpkgs-unstable-latest.to = {
        type = "tarball";
        url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
      };
      # templates # gets shortcutted by determinate nix ; see https://github.com/DeterminateSystems/nix-src/issues/339
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "cgroups"
        "git-hashing"
        "no-url-literals"
        "local-overlay-store"
        "pipe-operators"
        "verified-fetches"
      ];
    };
  };

  boot = {
    kernelPackages =
      cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages-cachyos-latest-lto-x86_64-v3;
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    kernel.sysctl."vm.swappiness" = 100;
  };

  zramSwap.enable = true;

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium ; also see https://github.com/NixOS/nixpkgs/issues/291051

  time.timeZone = "Europe/Paris";
  i18n = {
    extraLocaleSettings = {
      LANGUAGE = "en:fr";

      LC_ADDRESS = "fr_CH.UTF-8";
      LC_IDENTIFICATION = "fr_CH.UTF-8";
      LC_MEASUREMENT = "fr_CH.UTF-8";
      LC_MONETARY = "fr_CH.UTF-8";
      LC_NAME = "fr_CH.UTF-8";
      LC_NUMERIC = "fr_CH.UTF-8";
      LC_PAPER = "fr_CH.UTF-8";
      LC_TELEPHONE = "fr_CH.UTF-8";
      LC_TIME = "fr_CH.UTF-8";
    };
    extraLocales = [
      "fr_FR.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };

  console.keyMap = "fr";

  services = {

    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;

    printing.enable = true;

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

    flatpak.enable = true;

    ratbagd.enable = true;
  };

  hardware.bluetooth.enable = true;

  programs = {
    nix-ld.enable = true;
    bandwhich.enable = true;
    kdeconnect.enable = true;
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
      ghostty

      helix

      wget
      git
      fastfetch
      wl-clipboard-rs
      # clipboard-jh # broken for Wayland, see https://github.com/Slackadays/Clipboard/issues/171

      nixd
      nil
      nixfmt
      fh.packages.${pkgs.stdenv.hostPlatform.system}.default
      mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default

      piper

      cloudflare-warp
      protonvpn-gui
    ];

    etc.nixos.source = "/home/malix/Repositories/Malix-Labs/dotfiles/nix"; # string and not path for direct symlink (see https://discourse.nixos.org/t/how-to-create-symlinks-in-nixos/73911/4?u=malix)
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
    users.malix = ./home.nix;
  };

  users.users.malix = {
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
