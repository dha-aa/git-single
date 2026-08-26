#!/usr/bin/env bash

set -euo pipefail

# Basic settings
VERSION="1.1.6"
INSTALL_DIR="$HOME/.git-single"
SCRIPT_URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"
SCRIPT_PATH="$INSTALL_DIR/git-single"
OLD_SCRIPT_PATH="$INSTALL_DIR/git-single.sh"
ZSHRC="$HOME/.zshrc"
PATH_LINE="export PATH=\"$INSTALL_DIR:\$PATH\""

printf 'Installing git-single v%s...\n' "$VERSION"

# Create the install folders.
mkdir -p "$INSTALL_DIR/tmp" "$INSTALL_DIR/log"

# Remove the old command name, if an older version created it.
rm -f "$OLD_SCRIPT_PATH"

# Download the command without a .sh extension.
printf 'Downloading git-single...\n'
if ! curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"; then
    echo "Error: could not download git-single." >&2
    exit 1
fi
chmod +x "$SCRIPT_PATH"

# Make sure the zsh configuration file exists.
touch "$ZSHRC"

# Add the PATH line once.
if grep -Fq "$INSTALL_DIR" "$ZSHRC"; then
    echo "git-single is already in ~/.zshrc."
else
    {
        echo ""
        echo "# git-single"
        echo "$PATH_LINE"
    } >> "$ZSHRC"
    echo "Added git-single to ~/.zshrc."
fi

cat <<'MESSAGE'

Installation complete.

To use git-single in this terminal without restarting, run:

  source ~/.zshrc
  rehash

Then use:

  git-single <GitHub URL>
MESSAGE
