rec # to pass `nixConfig` as an argument
{
  inputs = {

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      # inputs.nixpkgs.follows # shoudln't be set, see https://github.com/xddxdd/nix-cachyos-kernel#how-to-use-kernels
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    l5p-keyboard-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-winpe = {
      url = "github:Malix-Labs/NixOS_WinPE";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.9";
    # nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agent-quota-timer-utils = {
      url = "https://gist.github.com/Malix-Labs/663d4910dfb3eb71018b1f1c2d9bcd64";
      type = "git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vaultix = {
      url = "github:milieuim/vaultix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-remote = {
      url = "github:Malix-Labs/Nix_Remote-Builders-Distributed";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
    };
  };

  nixConfig = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    lint-url-literals = "warn";
    log-lines = 50;

    extra-substituters = [
      "https://nix-community.cachix.org/"

      "https://attic.xuyh0120.win/lantian"
      "https://nix-cache.tokidoki.dev/tokidoki"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "tokidoki:MD4VWt3kK8Fmz3jkiGoNRJIW31/QAm7l1Dcgz2Xa4hk="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      nixpkgs-chosen = inputs.nixpkgs-unstable;

      username = "malix";
      hostName = "${username}-legion-nixos";
      usbHostName = "usb-remote";
      dotfilesDirectory = "Repositories/Malix-Labs/dotfiles";
      secretsDir = "./nix/users/${username}/secrets";

      ssh = {
        dir = ".ssh";
        keys = {
          master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEbJzrHvhXgm5jvL4clxiKcGSWt076D+kPZt+a+ZcRQ Malix - Alix Brunet";
          hosts = {
            ${hostName} =
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOm09W/QGDr5r1H/PymZ9GkO4R44eKxjRXy7HKLBc4AM root@malix-legion-nixos";
            ${usbHostName} =
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt75zBTjGYGtQVq+1FPVgQTzLUphihmah18Lm5iIFwX root@usb-remote";
          };
        };
      };

      specialArgs = inputs // {
        inherit
          nixConfig
          nixpkgs-chosen
          username
          hostName
          usbHostName
          dotfilesDirectory
          ssh
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
        inputs.vaultix.flakeModules.default
      ];

      systems = import inputs.systems;

      perSystem =
        {
          config,
          inputs',
          system,
          lib,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = inputs'.nixpkgs-unstable.legacyPackages;

          treefmt.programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };

          pre-commit.settings.hooks.treefmt.enable = true;

          checks = lib.optionalAttrs (system == "x86_64-linux") {
            toplevel = inputs.self.nixosConfigurations.${hostName}.config.system.build.toplevel;
          };

          packages.flash-usb-remote = pkgs.writeShellApplication {
            name = "flash-usb-remote";
            runtimeInputs = with pkgs; [
              rage
              coreutils
              util-linux
              inputs'.disko.packages.disko-install
            ];
            text = ''
              DISK="''${1:-/dev/disk/by-id/usb-Generic_Flash_Disk_0916027A-0:0}"

              if [ ! -b "$DISK" ]; then
                echo "Error: Target disk '$DISK' does not exist." >&2
                echo "Available block devices:" >&2
                lsblk -d -o NAME,SIZE,MODEL,TRAN,SERIAL
                exit 1
              fi

              SEED_DIR=$(mktemp -d /tmp/usb-seed.XXXXXX)
              cleanup() {
                rm -rf "$SEED_DIR"
              }
              trap cleanup EXIT

              USER_HOME=$(eval echo "~''${SUDO_USER:-$USER}")
              MASTER_KEY="''${MASTER_KEY:-$USER_HOME/.ssh/master}"
              SECRET_KEY_FILE="./nix/hosts/${usbHostName}/secrets/ssh_host_ed25519_key.age"

              mkdir -p "$SEED_DIR/persist/etc/ssh"

              if [ -f "$SECRET_KEY_FILE" ]; then
                echo "==> Decrypting host private key from $SECRET_KEY_FILE using $MASTER_KEY..."
                if [ ! -f "$MASTER_KEY" ]; then
                  echo "Error: Master key $MASTER_KEY not found." >&2
                  exit 1
                fi
                rage -d -i "$MASTER_KEY" "$SECRET_KEY_FILE" > "$SEED_DIR/persist/etc/ssh/ssh_host_ed25519_key"
                chmod 600 "$SEED_DIR/persist/etc/ssh/ssh_host_ed25519_key"
              else
                PART="''${DISK}-part2"
                if [ ! -b "$PART" ]; then
                  PART="''${DISK}2"
                fi
                if [ -b "$PART" ]; then
                  echo "==> Host key not in repo yet. Checking for existing key on $PART..."
                  MNT=$(mktemp -d /tmp/usb-old.XXXXXX)
                  if mount -o ro "$PART" "$MNT" 2>/dev/null; then
                    if [ -f "$MNT/nix/persist/etc/ssh/ssh_host_ed25519_key" ]; then
                      echo "==> Found existing host key on USB! Backing up and encrypting into $SECRET_KEY_FILE..."
                      mkdir -p "./nix/hosts/${usbHostName}/secrets"
                      rage -e -r "${ssh.keys.master}" "$MNT/nix/persist/etc/ssh/ssh_host_ed25519_key" > "$SECRET_KEY_FILE"
                      cp -a "$MNT/nix/persist/etc/ssh/ssh_host_ed25519_key" "$SEED_DIR/persist/etc/ssh/"
                      chmod 600 "$SEED_DIR/persist/etc/ssh/ssh_host_ed25519_key"
                      echo "==> Host key successfully backed up and encrypted into repository."
                    fi
                    umount "$MNT"
                    rm -rf "$MNT"
                  fi
                fi
              fi

              if [ ! -f "$SEED_DIR/persist/etc/ssh/ssh_host_ed25519_key" ]; then
                echo "Error: Could not locate or decrypt host key." >&2
                echo "Ensure $SECRET_KEY_FILE exists or plug in the current USB with the key on partition 2." >&2
                exit 1
              fi

              echo "==> Partitioning and installing ${usbHostName} onto $DISK..."
              disko-install --flake ".#${usbHostName}" --disk main "$DISK" --extra-files "$SEED_DIR" /

              sync
              echo "==> Installation complete! $DISK is ready to boot."
            '';
          };

          apps.flash-usb-remote = {
            type = "app";
            program = "${config.packages.flash-usb-remote}/bin/flash-usb-remote";
          };

          devShells.default = config.pre-commit.devShell;
        };

      flake = {
        vaultix = {
          identity = "$HOME/${ssh.dir}/master";
          defaultSecretDirectory = secretsDir;
          cache = "${secretsDir}/cache"; # see https://github.com/milieuim/vaultix/issues/64
        };

        nixosConfigurations.${hostName} = nixpkgs-chosen.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            inputs.vaultix.nixosModules.vaultix
            inputs.determinate.nixosModules.default

            inputs.lanzaboote.nixosModules.lanzaboote

            ./nix/base.nix
            ./nix/configuration.nix

            ./nix/hardware-configuration.nix
            inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6h-hybrid # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/legion/15ach6h
            inputs.nixos-winpe.nixosModules.lenovo-legion-15ach6h
            ./nix/nixos-hardware-override.nix
            inputs.disko.nixosModules.disko
            ./nix/disko.nix

            inputs.home-manager.nixosModules.default
            { home-manager.extraSpecialArgs = specialArgs; }
          ];
        };

        nixosConfigurations.${usbHostName} = nixpkgs-chosen.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            inputs.vaultix.nixosModules.vaultix
            inputs.impermanence.nixosModules.default
            inputs.disko.nixosModules.disko
            ./nix/hosts/${usbHostName}/disko.nix
            ./nix/hosts/${usbHostName}/configuration.nix
          ];
        };

        deploy.nodes.${usbHostName} =
          let
            targetConfig = inputs.self.nixosConfigurations.${usbHostName};
          in
          {
            hostname = usbHostName;
            profiles.system = {
              user = "root";
              sshUser = "root";
              path =
                inputs.deploy-rs.lib.${targetConfig.pkgs.stdenv.hostPlatform.system}.activate.nixos
                  targetConfig;
            };
          };
      };
    };
}
