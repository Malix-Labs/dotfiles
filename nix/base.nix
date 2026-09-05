{
  pkgs,
  lib,
  nixpkgs-chosen,
  nixpkgs-unstable,
  nixpkgs-stable,
  nixConfig,
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
  home-manager.extraSpecialArgs = extraPkgs;

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
      log-lines = lib.mkDefault 50;
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
