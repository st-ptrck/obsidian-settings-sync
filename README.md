# Obsidian Settings Sync

A Bash script for synchronizing Obsidian settings (`.obsidian` directory) across multiple Vaults.

## Disclaimer

> THIS SCRIPT COMES WITHOUT WARRANTY OF ANY KIND. <br>
> USE IT AT YOUR OWN RISK. <br>
> I ASSUME NO LIABILITY FOR THE USEFULNESS NOR FOR ANY SORT OF DAMAGES USING THIS SCRIPT MAY CAUSE. 


## Why This Script?

Obsidian users often maintain multiple Vaults for different purposes (personal, work, projects, etc.) and want to keep consistent settings, themes, and plugins across them. This script automates the process of copying your settings from one Vault to others.


## Important Notes

- **This will completely replace the `.obsidian` directory in destination Vaults**
- Plugin settings, themes, CSS snippets, hotkeys, and workspace layouts will all be synced
- You may need to restart Obsidian in destination Vaults to see changes
- Some plugins might have Vault-specific settings that you'll need to reconfigure
- Your configuration files (with `.conf` extension) will not be tracked by git


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
chmod +x obsidian-settings-sync.sh
```


3. Create a configuration file for your Vaults:
- You can create a copy from the template:
```
cp vaults.conf.template my-vaults.conf
```
- Or let the script create one for you when you first run it.

4. Add your Vault paths to the configuration file (one per line).

## Usage

- Run the script with your source Vault as the parameter:

```
./obsidian-settings-sync.sh /path/to/your/source/vault
```

The script will use the default configuration file at `~/.config/obsidian-settings-sync/vaults.conf`.


- Use a custom configuration file:

```
./obsidian-settings-sync.sh /path/to/your/source/vault --config ./my-vaults.conf
```


- Preview what would happen without making changes:

```
./obsidian-settings-sync.sh /path/to/your/source/vault --dry-run
```


## Configuration Files

### Default Location

The script looks for a configuration file at `~/.config/obsidian-settings-sync/vaults.conf` by default.

### Custom Configuration

You can specify a custom configuration file with the `--config` option. If the file doesn't exist, the script will offer to create it from the template.

### Configuration Format

The configuration file is a simple text file with one Vault path per line. Blank lines are ignored.


### Template

The repository includes a `vaults.conf.template` file with examples and instructions. You can copy this template to create your own configuration file:

```
cp vaults.conf.template my-vaults.conf
```


## Safety Features

- Requires explicit confirmation before making changes
- Supports dry-run mode for previewing changes
- Never creates new Vaults - only syncs to existing ones
- Skips the source Vault if it's also in the destination list
- Verifies each destination is a valid Obsidian Vault before syncing
- Validates configuration files before proceeding


## License

This project is licensed under the MIT License - see the LICENSE file for details.
