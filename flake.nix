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

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.6";
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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  nixConfig = {
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
    inputs@{
      self,
      nixpkgs-unstable,

      determinate,

      nixos-hardware,
      disko,

      home-manager,

      lanzaboote,

      treefmt-nix,
      git-hooks,

      ...
    }:
    let
      system = "x86_64-linux";
      nixpkgs-chosen = nixpkgs-unstable;
      pkgs = nixpkgs-chosen.legacyPackages.${system};

      username = "malix";
      hostName = "${username}-legion-nixos";
      dotfilesDirectory = "Repositories/Malix-Labs/dotfiles";

      specialArgs = inputs // {
        inherit
          nixpkgs-chosen

          username
          hostName
          dotfilesDirectory
          ;
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      };

      preCommitCheck = git-hooks.lib.${system}.run {
        src = ./.;
        hooks.treefmt = {
          enable = true;
          package = treefmtEval.config.build.wrapper;
        };
      };
    in
    {
      nixosConfigurations.${hostName} = nixpkgs-chosen.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          determinate.nixosModules.default

          lanzaboote.nixosModules.lanzaboote

          ./nix/configuration.nix

          ./nix/hardware-configuration.nix
          ./nix/pkgs.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h-hybrid # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nix/nixos-hardware-override.nix
          disko.nixosModules.disko
          # ./disko.nix

          home-manager.nixosModules.default
          { home-manager.extraSpecialArgs = specialArgs; }
        ];
      };

      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system} = {
        inherit preCommitCheck;
        toplevel = self.nixosConfigurations.${hostName}.config.system.build.toplevel;
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (preCommitCheck) shellHook;
      };
    };
}
