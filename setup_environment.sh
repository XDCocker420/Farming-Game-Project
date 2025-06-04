#!/bin/bash
set -e
# Install dependencies for running tests
# Install gdtoolkit for gdlint
pip install --user gdtoolkit

# Install Godot 4.4
GODOT_URL="https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -L "$GODOT_URL" -o godot.zip
unzip -q godot.zip
sudo mv Godot_v4.4-stable_linux.x86_64 /usr/local/bin/godot4
sudo chmod +x /usr/local/bin/godot4
cd -
rm -rf "$TMP_DIR"

echo "Godot version: $(godot4 --version)"
