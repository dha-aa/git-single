#!/bin/bash

set -e

SCRIPT_URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"

download_file() {
    url="$1"
    filename="$2"
    dir="$3"

    if [ -n "$dir" ]; then
        mkdir -p "$dir"
        curl -L "$url" -o "$dir/$filename"
    else
        curl -L "$url" -o "$filename"
    fi

    echo "Downloaded: $filename"
}

get_dir() {
    url="$1"

    username=$(echo "$url" | cut -d'/' -f4)
    repo=$(echo "$url" | cut -d'/' -f5)
    branch=$(echo "$url" | cut -d'/' -f7)
    dir=$(echo "$url" | cut -d'/' -f8)

    mkdir -p "$dir"

    curl -Ls "$url" |
        grep -oE "/$dir/[^\"?#]+" |
        sed "s|/$dir/||" |
        sort -u |
        while read -r file; do
            download_file \
                "https://raw.githubusercontent.com/$username/$repo/refs/heads/$branch/$dir/$file" \
                "$file" \
                "$dir"
        done
}

get_file() {
    url="$1"

    username=$(echo "$url" | cut -d'/' -f4)
    repo=$(echo "$url" | cut -d'/' -f5)
    branch=$(echo "$url" | cut -d'/' -f7)

    parts=$(echo "$url" | cut -d'/' -f8-)

    file=$(basename "$parts")
    dir=$(dirname "$parts")

    if [ "$dir" = "." ]; then
        raw_path="$file"
    else
        raw_path="$dir/$file"
    fi

    download_file \
        "https://raw.githubusercontent.com/$username/$repo/refs/heads/$branch/$raw_path" \
        "$file"
}

uninstall() {
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    install_dir="$(dirname "$script_path")"

    if [ "$(basename "$install_dir")" != ".git-single" ]; then
        echo "Uninstall is available from the installed git-single command." >&2
        exit 1
    fi

    rm -f "$script_path"
    rmdir "$install_dir" 2>/dev/null || true
    echo "git-single uninstalled. The PATH entry was left in place and is harmless."
}

update() {
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    temporary_file="$(mktemp)"

    curl -fsSL "$SCRIPT_URL" -o "$temporary_file"
    install -m 755 "$temporary_file" "$script_path"
    rm -f "$temporary_file"
    echo "git-single updated successfully."
}

show_help() {
    echo "Usage: git-single <GitHub blob/tree URL>"
    echo "       git-single --update"
    echo "       git-single --uninstall"
}

command="${1:-}"

if [ "$command" = "--update" ]; then
    update
elif [ "$command" = "--uninstall" ]; then
    uninstall
elif [ "$command" = "--help" ] || [ "$command" = "-h" ] || [ -z "$command" ]; then
    show_help
elif [[ "$command" == *"tree"* ]]; then
    get_dir "$command"
elif [[ "$command" == *"blob"* ]]; then
    get_file "$command"
else
    echo "Either you are putting the wrong URL or the URL is not a GitHub file/directory URL."
fi
