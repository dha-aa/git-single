# Git Single

## Overview

`git-single` is a Bash script that allows you to clone a single file or directory from a GitHub repository using sparse checkout. This minimizes unnecessary downloads and simplifies access to specific files.

## Features

* Clone a **single file** from a GitHub repository.
* Clone a **specific directory** without downloading the entire repo.
* Lightweight and fast.
* Simple to use with a single command.

## Installation

To install `git-single` in your home directory, run:

```bash
curl -fsSL https://raw.githubusercontent.com/dha-aa/git-single/main/git-single.sh -o ~/.git-single/git-single.sh &&
chmod +x ~/.git-single/git-single.sh
```

Add the following to your shell configuration (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PATH="$HOME/.git-single:$PATH"
```

Then reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

Note: The script uses `~/.git-single/tmp/` as a temporary directory for cloning repositories and `~/.git-single/log/` for logging. These directories are automatically created and cleaned up as needed.

## Usage

### Clone a Single File

```bash
git-single https://github.com/user/repo/blob/main/path/to/file.ts
```

This will download only `file.ts` and place it in the current directory.

### Clone a Specific Directory

```bash
git-single https://github.com/user/repo/tree/main/path/to/directory
```

This will clone only the `directory` inside the repository to the current working directory.

### Additional Commands

```bash
git-single --help      # Show help message
git-single --version   # Show version information
```

## Updating `git-single`

To update the script to the latest version, run:

```bash
git-single --update
```

## Uninstall `git-single`

To uninstall the script, run:

```bash
git-single --uninstall
```

## License

This project is licensed under the MIT License. Feel free to use and contribute!

