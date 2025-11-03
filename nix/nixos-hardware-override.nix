# Hardware Overrides for Lenovo Legion 15ACH6H

{
  config,
  lib,
  pkgs,
  l5p-keyboard-rgb,
  ...
}:
{
  hardware.nvidia.prime.amdgpuBusId = "PCI:5:0:0"; # See https://github.com/NixOS/nixos-hardware/issues/1388

  # Required until NixOS 25.11 is released OR https://github.com/NixOS/nixpkgs/issues/429624 gets fixed
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "580.95.05";
    sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
    sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
    openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
    settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
    persistencedSha256 = "sha256-QCwxXQfG/Pa7jSTBB0xD3lsIofcerAWWAHKvWjWGQtg=";
  };

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = [
    pkgs.lenovo-legion
    l5p-keyboard-rgb.packages.${pkgs.system}.default
  ];
}
