# initdev
Bash script to run right after startup.

## Overview

This small script automates basic local development environment tasks (updating repos). It’s intended as a convenience tool for team members and is provided "as-is".

## What you can/should modify

- WORK_REPO: Edit the `WORK_REPO` variable inside `init.sh` to point to your main working repository directory (e.g. change the default path to your project).

### Make the script executable

Before running, update the file permissions so it can be executed. From your shell run:

```zsh
chmod +x "$HOME/dev/init/init.sh"
```

### Suggested alias for easy use

Add a short alias to your shell config (for example `~/.zshrc`) to run the script with a simple command. Example:

```zsh
# Add to ~/.zshrc
alias initdev="$HOME/dev/init/init.sh"
# Then reload your shell or run
source ~/.zshrc
```

### Review and adapt

Please read the script and adapt it to your environment before using. It may assume certain tools or repository layouts (git and brew). Adjust paths and commands as needed.

## Disclaimer

This script is immature and provided in good faith to help manage the development environment. It may not cover every case and could produce changes on your system. Use at your own risk — any consequences of running this script are the sole responsibility of the user.

## Usage examples

Run directly from the repository:

```zsh
# Execute by absolute path
"$HOME/dev/init/init.sh"

# Or with an alias after adding it to your shell config
initdev
```

## Contact

If you have improvements or fixes, please contribute and create a Pull Request.
