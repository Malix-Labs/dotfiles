{
  inputs = {
    determinate.url = "github:DeterminateSystems/determinate";

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    fh = {
      url = "github:DeterminateSystems/fh";
      inputs.nixpkgs.follows = "determinate/nixpkgs";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.0";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,

      determinate,

      nixpkgs-stable,
      nixpkgs-unstable,

      nixos-hardware,

      fh,
      mcp-nixos,
      l5p-keyboard-rgb,

      declarative-flatpak,
      # nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs-stable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            mcp-nixos
            pkgs-unstable
            fh
            l5p-keyboard-rgb
            ;
        };
        modules = [
          determinate.nixosModules.default

          ./configuration.nix

          ./hardware-configuration.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nixos-hardware-override.nix

          declarative-flatpak.nixosModules.default
          # nix-flatpak.nixosModules.default
        ];
      };
    };
}
