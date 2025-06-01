# /etc/nixos/configuration.nix
# This file contains your main NixOS system configuration.
# It is designed to be concise, focusing on user-specific settings and overrides.

{ config, lib, pkgs, ... }:

{
	# Enable experimental features for Nix CLI and Flakes.
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Bootloader Configuration
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.grub.enable = false; # Explicitly disable GRUB

	# Pin kernel version due to NVIDIA compatibility.
	# Note: You currently have 6.14.8 running, but your flake was set to 6.12.30.
	# If you encounter compilation issues again, revert to a known working kernel like 6.12.30.
	boot.kernelPackages = pkgs.linuxPackages_6_14;

	# Networking Configuration
	networking.hostName = "nixos"; # Define your hostname.
	networking.networkmanager.enable = true; # Enable network manager

	# Localization and Time
	time.timeZone = "Europe/Paris";
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "fr_FR.UTF-8";
		LC_IDENTIFICATION = "fr_FR.UTF-8";
		LC_MEASUREMENT = "fr_FR.UTF-8";
		LC_MONETARY = "fr_FR.UTF-8";
		LC_NAME = "fr_FR.UTF-8";
		LC_NUMERIC = "fr_FR.UTF-8";
		LC_PAPER = "fr_FR.UTF-8";
		LC_TELEPHONE = "fr_FR.UTF-8";
		LC_TIME = "fr_FR.UTF-8";
	};
	console.keyMap = "fr"; # Configure console keymap

	# Display Manager and Desktop Environment (GNOME implicitly enables X11 and libinput)
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;

	services.xserver.xkb = {
		layout = "fr";
		variant = "";
	};

	# Sound with PipeWire (Pulseaudio explicitly disabled)
	services.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};

	# Printing
	services.printing.enable = true;

	# User Configuration
	users.users.malix = {
		isNormalUser = true;
		description = "Malix";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			vesktop
			gh
			zed-editor.fhs
			vscode.fhs
			# gitkraken # commented out temporarily because the stable package doesn't build but the unstable one does so waiting for the backport
		];
	};

	# Package Management
	nixpkgs.config.allowUnfree = true; # Allow unfree packages

	# System-wide packages
	environment.systemPackages = with pkgs; [
		ghostty
		google-chrome
		fastfetch
		wget
		git
		helix
		clipboard-jh
		nixd
		nixfmt-rfc-style
	];

	# System state version
	system.stateVersion = "24.11";
}
