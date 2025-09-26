# /etc/nixos/flake.nix
{
  inputs = {
    determinate.url = "github:DeterminateSystems/determinate";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    fh.url = "github:DeterminateSystems/fh";

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.0.1";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    mcp-nixos.url = "github:utensils/mcp-nixos";
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
          inherit mcp-nixos pkgs-unstable fh;
        };
        modules = [
          determinate.nixosModules.default

          ./configuration.nix

          ./hardware-configuration.nix
          nixos-hardware.nixosModules.lenovo-legion-15ach6h # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
          ./nixos-hardware-override.nix

          declarative-flatpak.nixosModule
          # nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
