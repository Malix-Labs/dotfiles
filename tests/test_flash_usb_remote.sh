#!/usr/bin/env bash
set -e

# Test: Missing master key error path

echo "Running test: Missing master key error path"

# To avoid requiring root (for losetup) during CI tests, we patch out the
# block device check `[ -b "$DISK" ]` in a temporary copy of the script.
SCRIPT_COPY=$(mktemp /tmp/flash-usb-remote.XXXXXX.bash)
cp ./scripts/flash-usb-remote.bash "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

# Patch out the block device check
sed -i 's/if \[ ! -b "$DISK" \]; then/if false; then/' "$SCRIPT_COPY"

DISK="/tmp/dummy_disk_$(date +%s)"
touch "$DISK"

# Setup environment variables
export DOTFILES_DIR=$(mktemp -d /tmp/dotfiles.XXXXXX)
export USB_HOSTNAME="test-usb"
export MASTER_KEY="/tmp/non_existent_master_key_$(date +%s)"

# Create the secret key file so it triggers the tested path
SECRET_DIR="$DOTFILES_DIR/nix/hosts/$USB_HOSTNAME/secrets"
mkdir -p "$SECRET_DIR"
touch "$SECRET_DIR/ssh_host_ed25519_key.age"

# Run the script
set +e
OUTPUT=$(bash "$SCRIPT_COPY" "$DISK" 2>&1)
EXIT_CODE=$?
set -e

# Cleanup
rm -rf "$DOTFILES_DIR"
rm -f "$SCRIPT_COPY"
rm -f "$DISK"

# Verify results
FAILED=0
if [ $EXIT_CODE -ne 1 ]; then
    echo "FAIL: Expected exit code 1, got $EXIT_CODE"
    FAILED=1
fi

if ! echo "$OUTPUT" | grep -q "Error: Master key $MASTER_KEY not found."; then
    echo "FAIL: Did not find expected error message in output."
    echo "Output was:"
    echo "$OUTPUT"
    FAILED=1
fi

if [ "$FAILED" = "1" ]; then
    # Return 1 without calling exit 1 for compatibility with the bash test environment
    exit 1
fi

echo "PASS: test_flash_usb_remote.sh"
