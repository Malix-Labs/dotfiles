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
      "ca-derivations"
      "cgroups"
      "git-hashing"
      "no-url-literals"
      "local-overlay-store"
      "pipe-operators"
      "verified-fetches"
    ];
    substituters = [
      "https://cache.nixos.org/" # don't know if this one is included by default already
      "https://nix-community.cachix.org/"

      "https://hyprland.cachix.org/"

      "https://install.determinate.systems"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # don't know if this one is included by default already
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
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

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;

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
          Context.filesystems = [
            "xdg-run/pipewire-0"
            "xdg-run/app/com.discordapp.Discord:create"
            "xdg-run/discord-ipc-0"
          ];
          environment = {
            "SDL_AUDIO_DRIVER" = "pipewire";
          };
        };
      };

      # Workaround for unsupported overrides (see https://github.com/in-a-dil-emma/declarative-flatpak/issues/42#issuecomment-3400500573)
      preSwitchCommand = ''
        flatpak override --device=input org.vinegarhq.Sober
      '';
    };

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

  hardware.bluetooth.enable = true;

  programs = {
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

    audacity

    google-chrome

    cloudflare-warp
    protonvpn-gui
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other. See https://wiki.nixos.org/wiki/Podman
    };
    waydroid.enable = true;
  };

  users.users.malix = {
    isNormalUser = true;
    description = "Malix";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
    packages = with pkgs; [
      gh
      vesktop
      pkgs-unstable.zed-editor
      vscode
      gitkraken
      pkgs-unstable.github-copilot-cli

      simplex-chat-desktop
    ];
  };

  system.stateVersion = "24.11"; # NEVER MUTATE
}
