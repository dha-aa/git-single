#!/usr/bin/env bash

set -euo pipefail

VERSION="1.1.6"
INSTALL_DIR="$HOME/.git-single"
SCRIPT_URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"
SCRIPT_PATH="$INSTALL_DIR/git-single.sh"

echo "Installing git-single v$VERSION..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download the script
echo "Downloading script from $SCRIPT_URL..."
if curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"; then
    chmod +x "$SCRIPT_PATH"
    echo "✓ Script downloaded to $SCRIPT_PATH"
else
    echo "✗ Failed to download script"
    exit 1
fi

# Create necessary subdirectories
mkdir -p "$INSTALL_DIR/tmp"
mkdir -p "$INSTALL_DIR/log"
echo "✓ Created directories: $INSTALL_DIR/tmp and $INSTALL_DIR/log"

# Detect shell and add to PATH
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

# Add to PATH if not already there
PATH_EXPORT="export PATH=\"$HOME/.git-single:\$PATH\""
if ! grep -q "$HOME/.git-single" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# git-single" >> "$SHELL_CONFIG"
    echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
    echo "✓ Added git-single to PATH in $SHELL_CONFIG"
else
    echo "✓ git-single already in PATH"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To use git-single, either:"
echo "  1. Run: source $SHELL_CONFIG"
echo "  2. Or restart your terminal"
echo ""
echo "Then you can use: git-single <GitHub URL>"
