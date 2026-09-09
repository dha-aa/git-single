#!/bin/bash

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

command="$1"

if [[ "$command" == *"tree"* ]]; then
    get_dir "$command"
elif [[ "$command" == *"blob"* ]]; then
    get_file "$command"
else
    echo "Either you are putting the wrong URL or the URL is not a GitHub file/directory URL."
fi