#!/usr/bin/env bash

set -euo pipefail

DIR="${GIT_SINGLE_DIR:-$HOME/.git-single}"
BIN="$DIR/git-single"
URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"

shell_rc() {
    case "${SHELL##*/}" in
        zsh) printf '%s\n' "${ZDOTDIR:-$HOME}/.zshrc" ;;
        bash) printf '%s\n' "${BASH_ENV:-$HOME/.bashrc}" ;;
        *) printf '%s\n' "$HOME/.profile" ;;
    esac
}

add_to_path() {
    local rc
    rc="$(shell_rc)"
    touch "$rc"
    if ! grep -Fqx 'export PATH="$HOME/.git-single:$PATH"' "$rc"; then
        printf '\nexport PATH="$HOME/.git-single:$PATH"\n' >> "$rc"
    fi
}

install_git_single() {
    local tmp
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT
    curl -fsSL "$URL" -o "$tmp"
    mkdir -p "$DIR"
    install -m 755 "$tmp" "$BIN"
    add_to_path
    trap - EXIT
    rm -f "$tmp"
    echo "git-single installed successfully at $BIN"
    echo "Run: source $(shell_rc) or open a new shell."
}

case "${1:-install}" in
    install) install_git_single ;;
    -h|--help)
        sed -n '1,12p' "$0"
        echo "Usage: $0 [install]"
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "Usage: $0 [install]" >&2
        exit 2
        ;;
esac
