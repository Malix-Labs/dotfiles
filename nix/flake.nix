{
  inputs = {

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.3";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    fh = {
      url = "github:DeterminateSystems/fh";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/" # don't know if this one is included by default already
      "https://nix-community.cachix.org/"

      "https://hyprland.cachix.org/"

      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # don't know if this one is included by default already
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  outputs =
    inputs@{
      nixpkgs-stable,

      determinate,

      nixos-hardware,

      home-manager,

      ...
    }:
    let
      nixpkgs-chosen = nixpkgs-stable;
      specialArgs = inputs // {
        inherit nixpkgs-chosen;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs-chosen.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          determinate.nixosModules.default

          ./configuration.nix

          ./hardware-configuration.nix
          ./pkgs-lib.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nixos-hardware-override.nix

          home-manager.nixosModules.default
          { home-manager.extraSpecialArgs = specialArgs; }
        ];
      };
    };
}
