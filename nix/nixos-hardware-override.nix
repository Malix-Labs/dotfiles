# Hardware Overrides for Lenovo Legion 15ACH6H

{
  config,
  lib,
  pkgs,
  l5p-keyboard-rgb,
  ...
}:
{
  boot.blacklistedKernelModules = [ "nova_core" ]; # Required until https://github.com/NixOS/nixpkgs/issues/473350 is fixed

  hardware.nvidia.prime.amdgpuBusId = "PCI:5:0:0"; # See https://github.com/NixOS/nixos-hardware/issues/1388

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = [
    pkgs.lenovo-legion
    l5p-keyboard-rgb.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
