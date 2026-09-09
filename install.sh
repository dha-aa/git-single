#!/usr/bin/env bash

set -e

DIR="$HOME/.git-single"
URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.js"

mkdir -p "$DIR"

curl -fsSL "$URL" -o "$DIR/git-single"
chmod +x "$DIR/git-single"

echo 'export PATH="$HOME/.git-single:$PATH"' >> "$HOME/.zshrc"

echo "git-single installed!"
echo "Run: source ~/.zshrc"
