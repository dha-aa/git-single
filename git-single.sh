#!/bin/bash

set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh"

download_file() {
    url="$1"
    filename="$2"
    dir="${3:-}"

    if [ -n "$dir" ]; then
        mkdir -p "$dir/$(dirname "$filename")"
        curl  -fsSL "$url" -o "$dir/$filename"
    else
        curl  -fsSL "$url" -o "$filename"
    fi

    echo "Downloaded: $filename"
}

get_dir() {
    url="$1"

    username=$(echo "$url" | cut -d'/' -f4)
    repo=$(echo "$url" | cut -d'/' -f5)
    branch=$(echo "$url" | cut -d'/' -f7)
    path=$(echo "$url" | cut -d'/' -f8-)

    text=$(curl -fsSL "$url")

    regex="/$path/[^\"?#]+"

    matches=$(echo "$text" | grep -oE "$regex" | sed "s|/$path/||")

    files=$(echo "$matches" | sort -u)

    while read -r file; do
        [ -z "$file" ] && continue

        download_file \
            "https://raw.githubusercontent.com/$username/$repo/refs/heads/$branch/$path/$file" \
            "$file" \
            "$path" &
    done <<< "$files"

    wait
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

    if [ ! -f "$install_dir/.installed" ] && [ "$(basename "$script_path")" != "git-single" ]; then
        echo "Error: this is not an installed git-single command." >&2
        exit 1
    fi

    rm -f "$script_path"
    rm -f "$install_dir/.installed"
    rmdir "$install_dir" 2>/dev/null || true
    echo "git-single uninstalled. The PATH entry was left in place and is harmless."
}

update() {
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    temporary_file="$(mktemp)"
    trap 'rm -f "$temporary_file"' EXIT

    curl -fsSL "$SCRIPT_URL" -o "$temporary_file"
    install -m 755 "$temporary_file" "$script_path"
    trap - EXIT
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
elif [[ "$command" == https://github.com/*/tree/* ]]; then
    get_dir "$command"
elif [[ "$command" == https://github.com/*/blob/* ]]; then
    get_file "$command"
else
    echo "Error: expected a GitHub /blob/ or /tree/ URL." >&2
    exit 2
fi
