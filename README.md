# Git Single

## Overview

`git-single` is a Bash script that allows you to clone a single file or directory from a GitHub repository using sparse checkout. This minimizes unnecessary downloads and simplifies access to specific files.

## Features

- Clone a **single file** from a GitHub repository.
- Clone a **specific directory** without downloading the entire repo.
- Lightweight and fast.
- Simple to use with a single command.

## Installation

To install `git-single` globally, run:

```bash
sudo curl -o /usr/local/bin/git-single https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh
sudo chmod +x /usr/local/bin/git-single
```

Now you can use `git-single` from anywhere in your terminal.

## Usage

### Clone a Single File

```bash
git-single https://github.com/user/repo/blob/main/path/to/file.ts
```

This will download only `file` and place it in the current directory.

### Clone a Specific Directory

```bash
git-single https://github.com/user/repo/tree/main/path/to/directory
```

This will clone only `directory` inside the repository.

## Updating `git-single`

To update the script to the latest version, run:

```bash
git-single --update
```

## License

This project is licensed under the MIT License. Feel free to use and contribute!

