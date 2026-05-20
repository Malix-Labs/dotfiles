{
  inputs = {

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      # inputs.nixpkgs.follows # shoudln't be set, see https://github.com/xddxdd/nix-cachyos-kernel#how-to-use-kernels
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.6";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    fh = {
      url = "github:DeterminateSystems/fh";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org/"

      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  outputs =
    inputs@{
      nixpkgs-unstable,

      determinate,

      nixos-hardware,

      home-manager,

      ...
    }:
    let
      nixpkgs-chosen = nixpkgs-unstable;

      username = "malix";
      hostName = "${username}-legion-nixos";
      homeDirectory = "/home/${username}";
      dotfilesDirectory = "${homeDirectory}/Repositories/Malix-Labs/dotfiles";

      specialArgs = inputs // {
        inherit
          nixpkgs-chosen

          username
          hostName
          homeDirectory
          dotfilesDirectory
          ;
      };
    in
    {
      nixosConfigurations.${hostName} = nixpkgs-chosen.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          determinate.nixosModules.default

          ./configuration.nix

          ./hardware-configuration.nix
          ./pkgs-lib.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h-hybrid # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nixos-hardware-override.nix

          home-manager.nixosModules.default
          { home-manager.extraSpecialArgs = specialArgs; }
        ];
      };
    };
}
