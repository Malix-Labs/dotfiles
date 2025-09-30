# Lenovo Legion 15ACH6H of Malix

{
  config,
  lib,
  pkgs,
  l5p-keyboard-rgb,
  ...
}:

{
  # See https://github.com/NixOS/nixos-hardware/issues/1388
  hardware.nvidia.prime.amdgpuBusId = "PCI:5:0:0";

  hardware.nvidia.open = false; # Required until NixOS 25.11 is released OR https://github.com/NixOS/nixpkgs/issues/429624 gets fixed

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = [
    pkgs.lenovo-legion
    l5p-keyboard-rgb.packages.${pkgs.system}.default
  ];
}
