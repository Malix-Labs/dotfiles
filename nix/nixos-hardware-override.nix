# Hardware Overrides for Lenovo Legion 15ACH6H

{
  config,

  pkgs,

  l5p-keyboard-rgb,

  ...
}:
{
  hardware.nvidia = {
    prime.amdgpuBusId = "PCI:5:0:0"; # See https://github.com/NixOS/nixos-hardware/issues/1388
    # powerManagement.finegrained = true; # causes deadlock after a timeout
  };

  # hotfix nixos-hardware https://github.com/NixOS/nixos-hardware/pull/2002
  environment.sessionVariables = {
    KWIN_DRM_DEVICES = "/dev/dri/by-path/pci-0000:05:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card";
  };

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = with pkgs; [
    lenovo-legion
    l5p-keyboard-rgb.packages.${stdenv.hostPlatform.system}.default
  ];
}
