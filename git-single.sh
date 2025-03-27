#!/bin/bash

# Ensure correct usage
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GitHub File or Directory URL>"
    exit 1
fi

# Extract repository details from GitHub URL
URL="$1"
REPO_URL=$(echo "$URL" | sed -E 's#(https://github.com/[^/]+/[^/]+)/.*#\1.git#')
REPO_NAME=$(basename -s .git "$REPO_URL")

# Determine if URL points to a file or directory
if [[ "$URL" == *"/blob/main/"* ]]; then
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/blob/main/##')
    IS_FILE=true
else
    TARGET_PATH=$(echo "$URL" | sed -E 's#https://github.com/[^/]+/[^/]+/tree/main/##')
    IS_FILE=false
fi

# Clone repository with sparse checkout
git clone --depth=1 --filter=blob:none --sparse "$REPO_URL"
cd "$REPO_NAME" || { echo "Failed to enter repo directory"; exit 1; }

# Handle single file case
echo "Setting sparse checkout for $TARGET_PATH"
if [ "$IS_FILE" = true ]; then
    git sparse-checkout set --skip-checks "$TARGET_PATH"
else
    git sparse-checkout set "$TARGET_PATH"
fi

echo "Successfully cloned $TARGET_PATH from $REPO_URL"

# If it's a file, move it to the original working directory
if [ "$IS_FILE" = true ]; then
    mv "$TARGET_PATH" ../ || { echo "Error: File not found."; exit 1; }
    cd ..
    rm -rf "$REPO_NAME"
    echo "File $TARGET_PATH has been moved to $(pwd)"
fi