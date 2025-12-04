# Modular NixOS configuration
# This file imports all necessary modules from the modular structure
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  mcp-nixos,
  fh,
  ...
}:
{
  imports = [
    # Commons modules
    ./commons/nix-settings.nix
    ./commons/fonts.nix
    ./commons/virtualization.nix
    ./commons/system-packages.nix

    # OS-specific modules
    ./os/nixos/boot.nix
    ./os/nixos/desktop.nix
    ./os/nixos/localization.nix

    # Hardware configuration (generated)
    ./hardware-configuration.nix

    # Hardware-specific modules
    ./hardware/lenovo-legion-15ach6h

    # Host-specific configuration
    ./hosts/nixos
    ./hosts/nixos/users.nix
  ];

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.malix = import ./users/malix/home.nix;
  };
}
