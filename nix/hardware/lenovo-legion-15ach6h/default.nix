# Hardware configuration for Lenovo Legion 15ACH6H
# This module imports nixos-hardware and provides overrides
{
  config,
  lib,
  pkgs,
  l5p-keyboard-rgb,
  nixos-hardware,
  ...
}:
{
  imports = [
    nixos-hardware.nixosModules.lenovo-legion-15ach6h # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
  ];

  # Hardware Overrides for Lenovo Legion 15ACH6H
  hardware.nvidia.prime.amdgpuBusId = "PCI:5:0:0"; # See https://github.com/NixOS/nixos-hardware/issues/1388

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = [
    pkgs.lenovo-legion
    l5p-keyboard-rgb.packages.${pkgs.system}.default
  ];
}
