# Lenovo Legion 15ACH6H of Malix

{ config, lib, pkgs, ... }:

{
	# See https://github.com/NixOS/nixos-hardware/issues/1388
	hardware.nvidia.prime.amdgpuBusId = "PCI:5:0:0";
}
