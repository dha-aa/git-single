#!/bin/bash

VERSION="1.0.1"

LOG_FILE="$HOME/.git-single.log"
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

INSTALL_PATH="/usr/local/bin/git-single"

# Handle update
if [ "$#" -eq 1 ] && [ "$1" == "---update" ]; then
    log "Updating git-single..."
    if ! sudo curl -fsSL "https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh" -o "$INSTALL_PATH"; then
        log "Error: Failed to update git-single."
        exit 1
    fi
    sudo chmod +x "$INSTALL_PATH"
    log "git-single has been updated successfully."
    echo "git-single version $VERSION"
    exit 0
fi

# Handle uninstall
if [ "$#" -eq 1 ] && [ "$1" == "---uninstall" ]; then
    log "Uninstalling git-single..."
    if sudo rm -f "$INSTALL_PATH"; then
        log "git-single has been uninstalled successfully."
    else
        log "Error: Failed to uninstall git-single."
        exit 1
    fi
    exit 0
fi

# Handle version
if [ "$#" -eq 1 ] && [ "$1" == "---version" ]; then
    echo "git-single version $VERSION"
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GitHub File or Directory URL>"
    echo "       $0 ---update   # To update git-single"
    echo "       $0 ---uninstall   # To uninstall git-single"
    exit 1
fi

URL="$1"

# Ensure Git is installed
if ! command -v git &> /dev/null; then
    log "Error: Git is not installed."
    exit 1
fi

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    log "Error: curl is not installed."
    exit 1
fi

# Extract repository details from GitHub URL
REPO_URL=$(echo "$URL" | sed -E 's#(https://github.com/[^/]+/[^/]+)/.*#\1.git#')
REPO_NAME=$(basename -s .git "$REPO_URL")

log "Processing URL: $URL"

# Fetch the default branch dynamically (fallback to main if failed)
DEFAULT_BRANCH=$(git ls-remote --symref "$REPO_URL" HEAD 2>/dev/null | awk -F'[/ ]+' '/^ref:/ {print $3}')
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="main"
    log "Warning: Unable to determine default branch. Assuming 'main'."
fi

# Check if URL is for a file or directory
if echo "$URL" | grep -E "/blob/[^/]+/" > /dev/null; then
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/blob/[^/]+/##')
    RAW_URL="https://raw.githubusercontent.com/$(echo "$URL" | sed -E 's#https://github.com/([^/]+/[^/]+)/blob/([^/]+)/(.*)#\1/\2/\3#')"
    OUTPUT_FILE=$(basename "$TARGET_PATH")
    log "Fetching raw file from $RAW_URL"
    if ! curl -fsSL "$RAW_URL" -o "$OUTPUT_FILE"; then
        log "Error: Failed to download file. Network issue or file may be private."
        exit 1
    fi
    log "File downloaded as $OUTPUT_FILE"
    exit 0
elif echo "$URL" | grep -E "/tree/[^/]+/" > /dev/null; then
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/tree/[^/]+/##')
else
    log "Error: Invalid GitHub URL format."
    exit 1
fi

# Clone repository with sparse checkout
log "Cloning repository: $REPO_URL"
if ! git clone --depth=1 --filter=blob:none --sparse "$REPO_URL"; then
    log "Error: Git clone failed. Repository may be private or network issues occurred."
    exit 1
fi
cd "$REPO_NAME" || { log "Error: Failed to enter repo directory."; exit 1; }

# Set sparse checkout
log "Setting sparse checkout for $TARGET_PATH"
if ! git sparse-checkout set "$TARGET_PATH"; then
    log "Error: Sparse checkout failed. Check if the path exists in the repository."
    exit 1
fi

# Move the fetched directory to the parent directory
if ! mv "$TARGET_PATH" ../; then
    log "Error: Directory not found. Check if the path is correct."
    exit 1
fi
log "Directory $TARGET_PATH has been moved to $(pwd)/.."

# Cleanup
cd ..
rm -rf "$REPO_NAME"
log "Cleanup completed."

exit 0
