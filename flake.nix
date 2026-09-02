rec # to pass `nixConfig` as an argument
{
  inputs = {

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      # inputs.nixpkgs.follows # shoudln't be set, see https://github.com/xddxdd/nix-cachyos-kernel#how-to-use-kernels
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-winpe = {
      url = "github:Malix-Labs/NixOS_WinPE";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.9";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agent-quota-timer-utils = {
      url = "https://gist.github.com/Malix-Labs/663d4910dfb3eb71018b1f1c2d9bcd64";
      type = "git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vaultix = {
      url = "github:milieuim/vaultix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  nixConfig = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "cgroups"
      "git-hashing"
      "local-overlay-store"
      "pipe-operators"
      "verified-fetches"
    ];
    lint-url-literals = "warn";
    extra-trusted-users = [ "@wheel" ];

    extra-substituters = [
      "https://nix-community.cachix.org/"

      "https://attic.xuyh0120.win/lantian"
      "https://nix-cache.tokidoki.dev/tokidoki"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "tokidoki:MD4VWt3kK8Fmz3jkiGoNRJIW31/QAm7l1Dcgz2Xa4hk="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      nixpkgs-chosen = inputs.nixpkgs-unstable;

      username = "malix";
      hostName = "${username}-legion-nixos";
      dotfilesDirectory = "Repositories/Malix-Labs/dotfiles";
      secretsDir = "./nix/users/${username}/secrets";

      ssh = {
        dir = ".ssh";
        keys = {
          master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEbJzrHvhXgm5jvL4clxiKcGSWt076D+kPZt+a+ZcRQ Malix - Alix Brunet";
        };
        host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOm09W/QGDr5r1H/PymZ9GkO4R44eKxjRXy7HKLBc4AM root@malix-legion-nixos";
      };

      specialArgs = inputs // {
        inherit
          nixConfig
          nixpkgs-chosen
          username
          hostName
          dotfilesDirectory
          ssh
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
        inputs.vaultix.flakeModules.default
      ];

      systems = import inputs.systems;

      perSystem =
        {
          config,
          inputs',
          system,
          lib,
          ...
        }:
        {
          _module.args.pkgs = inputs'.nixpkgs-unstable.legacyPackages;

          treefmt.programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };

          pre-commit.settings.hooks.treefmt.enable = true;

          checks = lib.optionalAttrs (system == "x86_64-linux") {
            toplevel = inputs.self.nixosConfigurations.${hostName}.config.system.build.toplevel;
          };

          devShells.default = config.pre-commit.devShell;
        };

      flake = {
        vaultix = {
          identity = "$HOME/${ssh.dir}/master";
          defaultSecretDirectory = secretsDir;
          cache = "${secretsDir}/cache"; # see https://github.com/milieuim/vaultix/issues/64
        };

        nixosConfigurations.${hostName} = nixpkgs-chosen.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            inputs.vaultix.nixosModules.vaultix
            inputs.determinate.nixosModules.default

            inputs.lanzaboote.nixosModules.lanzaboote

            ./nix/configuration.nix

            ./nix/hardware-configuration.nix
            ./nix/pkgs.nix
            inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6h-hybrid # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
            inputs.nixos-winpe.nixosModules.lenovo-legion-15ach6h
            ./nix/nixos-hardware-override.nix
            inputs.disko.nixosModules.disko
            ./nix/disko.nix

            inputs.home-manager.nixosModules.default
            { home-manager.extraSpecialArgs = specialArgs; }
          ];
        };
      };
    };
}
