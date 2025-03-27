#!/bin/bash

# Ensure correct usage
if [ "$#" -eq 1 ] && [ "$1" == "---update" ]; then
    INSTALL_PATH="/usr/local/bin/git-single"
    echo "Updating git-single..."
    sudo curl -fsSL "https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh" -o "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
    echo "git-single has been updated successfully."
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GitHub File or Directory URL>"
    echo "       $0 ---update   # To update git-single"
    exit 1
fi

URL="$1"

# Ensure Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed."
    exit 1
fi

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed."
    exit 1
fi

# Extract repository details from GitHub URL
REPO_URL=$(echo "$URL" | sed -E 's#(https://github.com/[^/]+/[^/]+)/.*#\1.git#')
REPO_NAME=$(basename -s .git "$REPO_URL")

# Fetch the default branch dynamically (fallback to main if failed)
DEFAULT_BRANCH=$(git ls-remote --symref "$REPO_URL" HEAD | awk -F'[/ ]+' '/^ref:/ {print $3}')
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="main"
    echo "Warning: Unable to determine default branch. Assuming 'main'."
fi

# Check if URL is for a file or directory
if echo "$URL" | grep -E "/blob/[^/]+/" > /dev/null; then
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/blob/[^/]+/##')
    RAW_URL="https://raw.githubusercontent.com/$(echo "$URL" | sed -E 's#https://github.com/([^/]+/[^/]+)/blob/([^/]+)/(.*)#\1/\2/\3#')"
    OUTPUT_FILE=$(basename "$TARGET_PATH")
    echo "Fetching raw file from $RAW_URL"
    curl -fsSL "$RAW_URL" -o "$OUTPUT_FILE" || { echo "Error: Failed to download file."; exit 1; }
    echo "File downloaded as $OUTPUT_FILE"
    exit 0
elif echo "$URL" | grep -E "/tree/[^/]+/" > /dev/null; then
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/tree/[^/]+/##')
else
    echo "Error: Invalid GitHub URL format."
    exit 1
fi

# Clone repository with sparse checkout
git clone --depth=1 --filter=blob:none --sparse "$REPO_URL" || { echo "Error: Git clone failed."; exit 1; }
cd "$REPO_NAME" || { echo "Error: Failed to enter repo directory."; exit 1; }

# Set sparse checkout
echo "Setting sparse checkout for $TARGET_PATH"
git sparse-checkout set "$TARGET_PATH" || { echo "Error: Sparse checkout failed."; exit 1; }

# Move the fetched directory to the parent directory
mv "$TARGET_PATH" ../ || { echo "Error: Directory not found."; exit 1; }
echo "Directory $TARGET_PATH has been moved to $(pwd)/.."

# Cleanup
cd ..
rm -rf "$REPO_NAME"

exit 0
