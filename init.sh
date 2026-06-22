#!/usr/bin/env bash
set -e
echo "=== Aerial Assault — Init ==="
echo "Checking test environment..."
cd "$(dirname "$0")"
if [ -f tests/harness.sh ]; then
  echo "Test harness found."
else
  echo "WARNING: tests/harness.sh missing"
fi
echo "Init complete."
