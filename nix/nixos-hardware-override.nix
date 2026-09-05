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
  };

  # Add Lenovo Legion kernel module and userspace utility
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  environment.systemPackages = with pkgs; [
    lenovo-legion
    l5p-keyboard-rgb.packages.${stdenv.hostPlatform.system}.default
  ];

  # Udev rules for Lenovo Legion RGB Keyboard (L5P-Keyboard-RGB)
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="usb", ATTR{idVendor}=="048d", MODE="0666"
  #   KERNEL=="hidraw*", ATTRS{idVendor}=="048d", MODE="0666"
  # '';
}
