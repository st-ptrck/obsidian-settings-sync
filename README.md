# Obsidian Settings Sync

A Bash script for synchronizing Obsidian settings (`.obsidian` directory) across multiple Vaults.

## Why This Script?

Obsidian users often maintain multiple Vaults for different purposes (personal, work, projects, etc.) and want to keep consistent settings, themes, and plugins across them. This script automates the process of copying your settings from one Vault to others.

## Features

- Only syncs to existing Vaults with valid Obsidian structure
- Displays warning and requires confirmation before making changes
- Supports dry-run mode to preview changes without applying them
- Offers template-based configuration for quick setup 

## Requirements

- Bash shell (available on Linux, macOS, WSL)
- Obsidian Vaults with `.obsidian` directories

## Setup

1. Clone or download this repository:

```
git clone https://github.com/st-ptrck/obsidian-settings-sync.git && cd obsidian-settings-sync
```


2. Make the script executable:

```
chmod +x obsidian-settings-synq.sh
```


3. Create a configuration file for your Vaults:
- You can create a copy from the template:
  ```
  cp vaults.conf.template my-vaults.conf
  ```
- Or let the script create one for you when you first run it.

4. Edit the configuration file and add your Vault paths (one per line).

## Usage

1. Run the script with your source Vault as the parameter:

```
./obsidian-settings-synq.sh /path/to/your/main/vault
```

The script will use the default configuration file at `~/.config/obsidian-settings-sync/vaults.conf`.

### Advanced Usage

Use a custom configuration file:

./obsidian-settings-synq.sh /path/to/your/main/vault --config ./my-vaults.conf


Preview what would happen without making changes:

./obsidian-settings-synq.sh /path/to/your/main/vault --dry-run


Combine options:

./obsidian-settings-synq.sh /path/to/your/main/vault --config ./my-vaults.conf --dry-run


Get help:

./obsidian-settings-synq.sh --help


## Configuration Files

### Default Location

The script looks for a configuration file at `~/.config/obsidian-settings-sync/vaults.conf` by default.

### Custom Configuration

You can specify a custom configuration file with the `--config` option. If the file doesn't exist, the script will offer to create it from the template.

### Configuration Format

The configuration file is a simple text file with one vault path per line:

Comments start with
/home/user/Documents/PersonalVault /home/user/Documents/WorkVault

Blank lines are ignored
/home/user/Documents/ProjectsVault


### Template

The repository includes a `vaults.conf.template` file with examples and instructions. You can copy this template to create your own configuration file:

cp vaults.conf.template my-vaults.conf


## Safety Features

- Requires explicit confirmation before making changes
- Supports dry-run mode for previewing changes
- Never creates new vaults - only syncs to existing ones
- Skips the source vault if it's also in the destination list
- Verifies each destination is a valid Obsidian vault before syncing
- Provides clear warnings when skipping vaults
- Validates configuration files before proceeding

## Important Notes

- **This will completely replace the `.obsidian` directory in destination vaults**
- Plugin settings, themes, CSS snippets, hotkeys, and workspace layouts will all be synced
- You may need to restart Obsidian in destination vaults to see changes
- Some plugins might have vault-specific settings that you'll need to reconfigure
- Your configuration files (with `.conf` extension) will not be tracked by git

## License

This project is licensed under the MIT License - see the LICENSE file for details.
