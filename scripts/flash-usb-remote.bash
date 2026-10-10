#!/usr/bin/env bash
set -euo pipefail

USB_HOSTNAME="${USB_HOSTNAME:-usb-remote}"
MASTER_KEY_PUB="${MASTER_KEY_PUB:-ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEbJzrHvhXgm5jvL4clxiKcGSWt076D+kPZt+a+ZcRQ Malix - Alix Brunet}"

DISK="${1:-/dev/disk/by-id/usb-Generic_Flash_Disk_0916027A-0:0}"

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

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
MASTER_KEY="${MASTER_KEY:-$USER_HOME/.ssh/master}"
SECRET_KEY_FILE="./nix/hosts/$USB_HOSTNAME/secrets/ssh_host_ed25519_key.age"

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
  PART="${DISK}-part2"
  if [ ! -b "$PART" ]; then
    PART="${DISK}2"
  fi
  if [ -b "$PART" ]; then
    echo "==> Host key not in repo yet. Checking for existing key on $PART..."
    MNT=$(mktemp -d /tmp/usb-old.XXXXXX)
    if mount -o ro "$PART" "$MNT" 2>/dev/null; then
      if [ -f "$MNT/nix/persist/etc/ssh/ssh_host_ed25519_key" ]; then
        echo "==> Found existing host key on USB! Backing up and encrypting into $SECRET_KEY_FILE..."
        mkdir -p "./nix/hosts/$USB_HOSTNAME/secrets"
        rage -e -r "$MASTER_KEY_PUB" "$MNT/nix/persist/etc/ssh/ssh_host_ed25519_key" > "$SECRET_KEY_FILE"
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

echo "==> Partitioning and installing $USB_HOSTNAME onto $DISK..."
disko-install --flake ".#$USB_HOSTNAME" --disk main "$DISK" --extra-files "$SEED_DIR" /

sync
echo "==> Installation complete! $DISK is ready to boot."
