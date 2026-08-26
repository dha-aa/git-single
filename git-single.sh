#!/usr/bin/env bash

set -euo pipefail

# Basic settings
VERSION="1.1.6"
INSTALL_DIR="$HOME/.git-single"
COMMAND_PATH="$INSTALL_DIR/git-single"
OLD_COMMAND_PATH="$INSTALL_DIR/git-single.sh"
SCRIPT_URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"
ZSHRC="$HOME/.zshrc"
TEMP_DIR="$INSTALL_DIR/tmp/git-single-temp"
LOG_FILE="$INSTALL_DIR/log/.git-single.log"

# The installer creates these folders, but creating them here also makes the
# script work when it is copied manually.
mkdir -p "$INSTALL_DIR/tmp" "$INSTALL_DIR/log"

# Write a small log entry. Logging must never stop the main command.
log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE" 2>/dev/null || true
}

# Remove temporary files when the command finishes or fails.
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Check a command only when that command is needed.
require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 is required but is not installed." >&2
        exit 1
    fi
}

show_help() {
    cat <<'HELP'
Usage:
  git-single <GitHub file or directory URL>
  git-single --update
  git-single --uninstall
  git-single --version
  git-single --help
HELP
}

# Remove exactly the lines added by the installer.
remove_path_from_zshrc() {
    local temp_file
    local path_line="export PATH=\"$INSTALL_DIR:\$PATH\""

    [ -f "$ZSHRC" ] || return 0

    temp_file=$(mktemp "${ZSHRC}.git-single.XXXXXX")

    awk -v comment="# git-single" -v path_line="$path_line" '
        $0 == comment || $0 == path_line { next }
        { print }
    ' "$ZSHRC" > "$temp_file"

    if ! cmp -s "$ZSHRC" "$temp_file"; then
        cat "$temp_file" > "$ZSHRC"
        echo "Removed git-single from ~/.zshrc."
    fi

    rm -f "$temp_file"
}

update_command() {
    require_command curl

    echo "Updating git-single..."
    if ! curl -fsSL "$SCRIPT_URL" -o "$COMMAND_PATH"; then
        echo "Error: update failed." >&2
        exit 1
    fi

    chmod +x "$COMMAND_PATH"
    rm -f "$OLD_COMMAND_PATH"
    echo "git-single updated."
}

uninstall_command() {
    echo "Uninstalling git-single..."
    remove_path_from_zshrc
    rm -rf "$INSTALL_DIR"
    echo "git-single has been removed."
    echo "Run: source ~/.zshrc && rehash"
}

download_file() {
    local user="$1"
    local repo="$2"
    local branch="$3"
    local file_path="$4"
    local raw_url="https://raw.githubusercontent.com/$user/$repo/$branch/$file_path"
    local output_file

    require_command curl

    # Save the file in the current directory using its original name.
    output_file=$(basename "$file_path")
    echo "Downloading $output_file..."

    if ! curl -fsSL "$raw_url" -o "$output_file"; then
        echo "Error: download failed." >&2
        exit 1
    fi

    echo "Downloaded $output_file."
}

download_directory() {
    local user="$1"
    local repo="$2"
    local branch="$3"
    local directory_path="$4"
    local repo_url="https://github.com/$user/$repo.git"
    local destination="$PWD/$directory_path"

    require_command git

    # Clone only the requested directory.
    rm -rf "$TEMP_DIR"
    mkdir -p "$(dirname "$destination")"

    echo "Downloading $directory_path..."
    if ! git clone --depth 1 --filter=blob:none --sparse "$repo_url" "$TEMP_DIR"; then
        echo "Error: could not clone the repository." >&2
        exit 1
    fi

    if ! git -C "$TEMP_DIR" sparse-checkout set "$directory_path"; then
        echo "Error: could not select the directory." >&2
        exit 1
    fi

    mv "$TEMP_DIR/$directory_path" "$destination"
    echo "Downloaded $directory_path."
}

# Handle commands that do not need a URL.
case "${1:-}" in
    --help)
        show_help
        exit 0
        ;;
    --version)
        echo "git-single version $VERSION"
        exit 0
        ;;
    --update)
        update_command
        exit 0
        ;;
    --uninstall)
        uninstall_command
        exit 0
        ;;
    "")
        echo "Error: please provide a GitHub URL or use --help." >&2
        exit 1
        ;;
esac

URL="$1"
log "Processing URL: $URL"

# A file URL looks like: /user/repository/blob/branch/path/to/file
if [[ "$URL" =~ ^https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$ ]]; then
    download_file "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
        "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    exit 0
fi

# A directory URL looks like: /user/repository/tree/branch/path/to/folder
if [[ "$URL" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
    download_directory "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
        "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    exit 0
fi

echo "Error: invalid GitHub URL. Use --help for examples." >&2
exit 1
