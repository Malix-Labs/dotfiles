{
  inputs = {
    determinate.url = "github:DeterminateSystems/determinate";

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.1";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    fh = {
      url = "github:DeterminateSystems/fh";
      inputs.nixpkgs.follows = "determinate/nixpkgs";
    };
    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs =
    inputs@{
      nixpkgs-stable,

      determinate,

      nixos-hardware,

      home-manager,

      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs-stable.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          determinate.nixosModules.default

          ./configuration.nix

          ./hardware-configuration.nix
          ./pkgs-lib.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nixos-hardware-override.nix

          home-manager.nixosModules.default
          { home-manager.extraSpecialArgs = inputs; }
        ];
      };
    };
}
