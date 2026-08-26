# git-single

`git-single` downloads one file or one directory from a GitHub repository without downloading the whole repository.

## Install

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/dha-aa/git-single/main/install.sh | bash
```

The installer:

- Saves the command as `~/.git-single/git-single`.
- Adds `~/.git-single` to `~/.zshrc`.
- Removes the old `git-single.sh` command name.

Use the command in the current terminal without restarting:

```zsh
source ~/.zshrc
rehash
```

## Usage

Download one file:

```bash
git-single https://github.com/user/repository/blob/main/path/to/file.txt
```

The file is saved in the current directory.

Download one directory:

```bash
git-single https://github.com/user/repository/tree/main/path/to/directory
```

The directory is downloaded into the current directory.

## Other commands

```bash
git-single --help
git-single --version
git-single --update
git-single --uninstall
```

`--uninstall` removes the installation and removes these exact lines from `~/.zshrc`:

```zsh
# git-single
export PATH="$HOME/.git-single:$PATH"
```

## Temporary files and logs

Temporary clone files are stored in `~/.git-single/tmp/`. Logs are stored in `~/.git-single/log/`.

## License

MIT
