# Modular NixOS Configuration Structure

This directory contains a modularized NixOS configuration that supports multiple operating systems, hardware configurations, hosts, and users.

## Directory Structure

```
nix/
├── commons/              # Common modules shared across configurations
│   ├── nix-settings.nix  # Nix daemon and flakes configuration
│   ├── fonts.nix         # Font configuration
│   ├── virtualization.nix # Virtualization settings (Podman, Waydroid)
│   └── system-packages.nix # System-wide packages
│
├── hardware/             # Hardware-specific configurations
│   └── lenovo-legion-15ach6h/ # Lenovo Legion 15ACH6H laptop
│       └── default.nix
│
├── os/                   # Operating system specific configurations
│   └── nixos/            # NixOS configurations
│       ├── boot.nix      # Boot loader configuration
│       ├── desktop.nix   # Desktop environment (Plasma 6, SDDM)
│       └── localization.nix # Locale and timezone settings
│
├── hosts/                # Host-specific configurations
│   └── nixos/            # Configuration for "nixos" host
│       ├── default.nix   # Host settings (hostname, network)
│       └── users.nix     # User definitions for this host
│
├── users/                # User-specific configurations
│   └── malix/            # Configuration for user "malix"
│       ├── home.nix      # Home Manager configuration
│       └── hosts/        # Host-specific user overrides
│           └── nixos/
│               └── home.nix
│
├── services/             # Service configurations (for future use)
│
├── configuration-modular.nix  # Main modular configuration entry point
├── configuration.nix          # Legacy configuration (kept for reference)
├── hardware-configuration.nix # Generated hardware configuration
├── flake.nix                  # Flake configuration
└── flake.lock                 # Flake lock file
```

## Usage

### Building the Configuration

The configuration uses `configuration-modular.nix` as the main entry point, which imports all necessary modules.

```bash
# Rebuild the system
sudo nixos-rebuild switch --flake .#nixos

# Or use the provided script
./rebuild.sh
```

### Adding a New Host

1. Create a new directory under `hosts/` with the host name
2. Add a `default.nix` file with host-specific settings
3. Add a `users.nix` file to define users for this host
4. Create corresponding user host directory under `users/*/hosts/`

### Adding a New User

1. Create a new directory under `users/` with the username
2. Add a `home.nix` file with Home Manager configuration
3. Create host-specific overrides under `users/*/hosts/<hostname>/`
4. Add user definition to the host's `users.nix`

### Adding Hardware Support

1. Create a new directory under `hardware/` with the hardware name
2. Add a `default.nix` file with hardware-specific settings
3. Import the hardware module in your host configuration or configuration-modular.nix

## Principles

- **Idempotent**: Configurations can be applied repeatedly with the same result
- **Universal**: Support for multiple OSes, hardware, hosts, and users
- **Modular**: Each aspect is separated into its own module
- **Extensible**: Easy to add new configurations without modifying existing ones

## Migration from Legacy Configuration

The original `configuration.nix` has been preserved for reference. The new modular structure provides:

- Clear separation of concerns
- Better reusability across hosts
- Easier maintenance and understanding
- Support for multiple users and hosts

## Future Enhancements

- Support for non-NixOS Linux distributions
- Support for macOS Darwin
- Additional hardware profiles
- Service-specific modules in the `services/` directory
