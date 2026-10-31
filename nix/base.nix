{
  config,
  pkgs,
  lib,
  nixpkgs-chosen,
  nixpkgs-unstable,
  nixpkgs-stable,
  nixConfig,
  ssh,
  username,
  vaultix,
  disko,
  ...
}:
let
  channels = {
    unstable = {
      flake = nixpkgs-unstable;
      branch = "nixos-unstable";
    };
    stable = {
      flake = nixpkgs-stable;
      branch = "nixos-26.05";
    };
  };

  extraPkgs =
    channels
    |> lib.concatMapAttrs (
      name: channel: {
        "pkgs-${name}" =
          if nixpkgs-chosen == channel.flake then
            pkgs
          else
            import channel.flake {
              inherit (pkgs) config;
              inherit (pkgs.stdenv.hostPlatform) system;
            };
      }
    );
in
{
  imports = [
    vaultix.nixosModules.vaultix
    disko.nixosModules.disko
  ];

  _module.args = extraPkgs;

  services.userborn.enable = lib.mkDefault true;
  zramSwap.enable = lib.mkDefault true;

  boot.tmp.useTmpfs = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Paris";
  i18n = {
    defaultLocale = lib.mkDefault "fr_CH.UTF-8";
    extraLocaleSettings.LANGUAGE = lib.mkDefault "en:C:fr";
  };
  console.keyMap = lib.mkDefault "fr";

  programs.git.enable = lib.mkDefault true;

  programs.nh = {
    enable = lib.mkDefault true;
    clean.enable = lib.mkDefault true;
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
    };
  };

  vaultix.settings.hostPubkey = lib.mkDefault ssh.hosts.${config.networking.hostName};

  users.users.root.openssh.authorizedKeys.keys = [ ssh.identities.master ];

  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    description = "Malix";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ ssh.identities.master ];
  };

  nix = {
    daemonCPUSchedPolicy = lib.mkDefault "batch";

    registry = {
      nixpkgs = lib.mkForce { flake = nixpkgs-chosen; }; # Override determinate
    }
    // (
      channels
      |> lib.concatMapAttrs (
        name: channel: {
          "nixpkgs-${name}".flake = channel.flake;
          "nixpkgs-${name}-latest".to = {
            type = "tarball";
            url = "https://channels.nixos.org/${channel.branch}/nixexprs.tar.xz";
          };
        }
      )
    );

    settings = nixConfig // {
      auto-optimise-store = lib.mkDefault true;
      builders-use-substitutes = lib.mkDefault true;
      use-xdg-base-directories = lib.mkDefault true;

      extra-trusted-users = if pkgs.stdenv.hostPlatform.isDarwin then [ "@admin" ] else [ "@wheel" ];
    };
  };

  systemd.services = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    nix-daemon.serviceConfig = {
      CPUWeight = lib.mkDefault 20;
      IOWeight = lib.mkDefault 20;
      MemoryHigh = lib.mkDefault "80%";
    };
  };
}
