# /etc/nixos/flake.nix
{
	description = "NixOS configuration with flakes";

	inputs = {
		# Pin nixpkgs to the stable 25.05 release branch for better compatibility.
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
	};

	outputs = { self, nixpkgs, nixos-hardware }: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
				./hardware-configuration.nix
				nixos-hardware.nixosModules.lenovo-legion-15ach6h
				./nixos-hardware-override.nix
			];
		};
	};
}
