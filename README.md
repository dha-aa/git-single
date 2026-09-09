# git-single

`git-single` is a simple CLI tool for downloading a **single file or directory from a GitHub repository** without downloading the entire repository.

## Features

* Download a single file from GitHub
* Download a directory from GitHub
* No need to clone the entire repository
* Simple command-line interface
* Built with Node.js
* Works with GitHub `blob` and `tree` URLs

## Requirements

* Node.js 18+
* `curl`
* macOS, Linux, or another Unix-like system

## Install

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/dha-aa/git-single/main/install.sh | bash
```

Then reload your shell:

```bash
source ~/.zshrc
```

Check that it works:

```bash
git-single
```

## Usage

### Download a file

Pass a GitHub `blob` URL:

```bash
git-single https://github.com/dha-aa/dropair/blob/main/server.js
```

The file will be downloaded into your current directory:

```text
server.js
```

### Download a directory

Pass a GitHub `tree` URL:

```bash
git-single https://github.com/dha-aa/voiceflow/tree/main/docs
```

The directory will be downloaded into your current directory:

```text
docs/
├── ...
```

## How it works

For a file, `git-single` converts the GitHub URL into a GitHub Raw URL and downloads the file directly.

```text
GitHub blob URL
      ↓
Parse repository + branch + file
      ↓
GitHub Raw URL
      ↓
Download file
```

For a directory, `git-single` reads the GitHub directory page, finds the files inside it, and downloads those files individually.

```text
GitHub tree URL
      ↓
Read directory page
      ↓
Find files
      ↓
Download files
      ↓
Create directory
```

## Examples

Download a file:

```bash
git-single https://github.com/dha-aa/dropair/blob/main/server.js
```

Download a directory:

```bash
git-single https://github.com/dha-aa/voiceflow/tree/main/docs
```

## Installation

The installer creates:

```text
~/.git-single/
└── git-single
```

The CLI is downloaded from this repository and installed as:

```text
~/.git-single/git-single
```

The installer also adds the directory to your shell `PATH`.

## Project Structure

```text
git-single/
├── git-single.js
├── install.sh
└── README.md
```

### `git-single.js`

The main CLI application.

It handles:

* GitHub URL parsing
* File downloads
* Directory downloads
* Creating directories
* Saving downloaded files

### `install.sh`

The installation script.

It:

1. Creates `~/.git-single`
2. Downloads `git-single.js`
3. Installs it as `~/.git-single/git-single`
4. Makes it executable
5. Adds `~/.git-single` to the shell `PATH`

## Limitations

Currently, `git-single` supports GitHub URLs using:

```text
/blob/
```

for files and:

```text
/tree/
```

for directories.

Private repositories and repositories requiring authentication are not currently supported.

## License

MIT
