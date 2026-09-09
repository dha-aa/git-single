# git-single

Download one file or one folder from a public GitHub repository without cloning the whole repository.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/dha-aa/git-single/main/install.sh | bash
```

Restart your terminal, or run:

```bash
source ~/.zshrc
```

Check the installation:

```bash
git-single --help
```

## Use

Download a file:

```bash
git-single https://github.com/OWNER/REPOSITORY/blob/BRANCH/path/to/file
```

Download a folder:

```bash
git-single https://github.com/OWNER/REPOSITORY/tree/BRANCH/path/to/folder
```

Downloaded files are saved in your current folder.

## Update or uninstall

```bash
git-single --update
git-single --uninstall
```

## Requirements

- macOS, Linux, or another Unix-like system
- Bash
- `curl`

## Notes

- Works with public GitHub repositories only.
- Use GitHub `blob` links for files and `tree` links for folders.
- Existing files with the same name may be replaced.

## License

MIT
