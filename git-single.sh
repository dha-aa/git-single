#!/bin/bash

set -euo pipefail

VERSION=1.0.5
INSTALL_PATH="/usr/local/bin/git-single"
TEMP_DIR="/tmp/git-single-temp"
LOG_FILE="$HOME/.git-single.log"

exec 3>>"$LOG_FILE"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&3; }

# Ensure dependencies exist
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        log "Error: $1 is not installed."
        echo "Error: $1 is required but not installed." >&2
        exit 1
    fi
}

check_dependency "git"
check_dependency "curl"

# Update function
update_script() {
    log "Updating git-single..."
    if sudo curl -fsSL "https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh" -o "$INSTALL_PATH"; then
        sudo chmod +x "$INSTALL_PATH"
        log "Update successful."
        echo "git-single updated to version $VERSION"
    else
        log "Error: Update failed."
        exit 2
    fi
    exit 0
}

# Uninstall function
uninstall_script() {
    log "Uninstalling git-single..."
    if sudo rm -f "$INSTALL_PATH"; then
        log "Uninstallation successful."
        echo "git-single has been removed."
    else
        log "Error: Uninstallation failed."
        exit 1
    fi
    exit 0
}

# Print help message
print_help() {
    echo "Usage: $0 <GitHub File or Directory URL>"
    echo "       $0 ---update       # Update git-single"
    echo "       $0 ---uninstall    # Uninstall git-single"
    echo "       $0 ---version      # Show version"
    echo "       $0 ---help         # Show this help message"
    exit 0
}

# Handle script arguments
case "${1:-}" in
    "---update") update_script ;;
    "---uninstall") uninstall_script ;;
    "---version") echo "git-single version $VERSION"; exit 0 ;;
    "---help") print_help ;;
    "") echo "Error: No argument provided. Use ---help for usage." >&2; exit 1 ;;
esac

URL="$1"
log "Processing URL: $URL"

# Extract repository details dynamically
clone_repo() {
    local REPO_URL="$1"
    local TARGET_PATH="$2"
    local CURRENT_DIR
    CURRENT_DIR="$(pwd)"

    # Clean and prepare temp directory
    [ -e "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"

    log "Cloning repository: $REPO_URL into $TEMP_DIR"
    if ! git clone --depth=1 --filter=blob:none --sparse "$REPO_URL" "$TEMP_DIR"; then
        log "Error: Git clone failed."
        exit 3
    fi

    cd "$TEMP_DIR" || { log "Error: Failed to enter temp repo directory."; exit 1; }

    log "Setting sparse checkout for $TARGET_PATH"
    if ! git sparse-checkout set "$TARGET_PATH"; then
        log "Error: Sparse checkout failed."
        exit 1
    fi

    # Return to original working directory
    cd "$CURRENT_DIR"

    # Create destination directory structure if needed
    mkdir -p "$(dirname "$CURRENT_DIR/$TARGET_PATH")"
    mv "$TEMP_DIR/$TARGET_PATH" "$CURRENT_DIR/$TARGET_PATH" || { log "Error: Moving directory failed."; exit 1; }

    log "Directory moved to $CURRENT_DIR/$TARGET_PATH"

    # Clean up
    rm -rf "$TEMP_DIR"
    log "Cleanup completed. Temp directory removed."
    exit 0
}

# Handle GitHub file URL
if [[ "$URL" =~ ^https://github.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$ ]]; then
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    FILE_PATH="${BASH_REMATCH[4]}"
    REPO_URL="https://github.com/$USER/$REPO.git"
    RAW_URL="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH/$FILE_PATH"
    OUTPUT_FILE=$(basename "$FILE_PATH")

    log "Fetching raw file from $RAW_URL"
    if curl -fsSL "$RAW_URL" -o "$OUTPUT_FILE"; then
        log "File downloaded: $OUTPUT_FILE"
    else
        log "Error: Failed to download file."
        exit 2
    fi
    exit 0

# Handle GitHub directory URL
elif [[ "$URL" =~ ^https://github.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    TARGET_PATH="${BASH_REMATCH[4]}"
    REPO_URL="https://github.com/$USER/$REPO.git"

    clone_repo "$REPO_URL" "$TARGET_PATH"

else
    log "Error: Invalid GitHub URL format."
    echo "Error: Invalid GitHub URL format. Use ---help for details." >&2
    exit 1
fi
