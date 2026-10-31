{
  config,
  pkgs,
  lib,
  nixpkgs-chosen,
  nixpkgs-unstable,
  nixpkgs-stable,
  nixConfig,
  ssh,
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
  _module.args = extraPkgs;

  services.userborn.enable = lib.mkDefault true;
  zramSwap.enable = lib.mkDefault true;

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
    };
  };

  vaultix.settings.hostPubkey = lib.mkDefault ssh.hosts.${config.networking.hostName};

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
