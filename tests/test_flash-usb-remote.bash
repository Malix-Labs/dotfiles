#!/usr/bin/env bash

# Test script for scripts/flash-usb-remote.bash

SCRIPT_TO_TEST="./scripts/flash-usb-remote.bash"
NON_EXISTENT_DISK="/dev/disk/by-id/non-existent-disk-12345"

echo "Running test: Missing target disk error path"

# Capture stderr and exit code
set +e
STDERR_OUTPUT=$( "$SCRIPT_TO_TEST" "$NON_EXISTENT_DISK" 2>&1 >/dev/null )
EXIT_CODE=$?
set -e

# Assertions
if [ "$EXIT_CODE" -ne 1 ]; then
  echo "FAIL: Expected exit code 1, but got $EXIT_CODE"
  exit 1
fi

if ! echo "$STDERR_OUTPUT" | grep -q "Error: Target disk '$NON_EXISTENT_DISK' does not exist."; then
  echo "FAIL: Expected error message not found in stderr"
  echo "Actual stderr:"
  echo "$STDERR_OUTPUT"
  exit 1
fi

if ! echo "$STDERR_OUTPUT" | grep -q "Available block devices:"; then
  echo "FAIL: Expected 'Available block devices:' not found in stderr"
  echo "Actual stderr:"
  echo "$STDERR_OUTPUT"
  exit 1
fi

echo "PASS: Missing target disk error path test passed successfully."
exit 0
