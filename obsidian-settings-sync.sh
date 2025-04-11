#!/bin/bash

# Obsidian Settings Sync Script
# This script copies the .obsidian settings directory from a source vault to other vaults.

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 <source_vault_path> [options]"
    echo ""
    echo "Options:"
    echo "  --config <file>    Specify a custom configuration file (overrides default)"
    echo "  --dry-run          Show what would be done without making any changes"
    echo "  --help             Show this help message and exit"
    echo ""
    echo "Default config location: '$DEFAULT_CONFIG_FILE'"
    echo ""
    echo "Example:"
    echo "  $0 ~/Documents/SourceVault --config ./my-vaults.conf"
    exit 1
}

# Process command line arguments
DRY_RUN=false
DEFAULT_CONFIG_FILE="$HOME/.config/obsidian-settings-sync/vaults.conf"
CUSTOM_CONFIG_FILE=""

if [ $# -lt 1 ]; then
    show_usage
fi

SOURCE_VAULT="$1"
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)
            CUSTOM_CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_usage
            ;;
        *)
            echo "Error: Unknown option '$1'"
            show_usage
            ;;
    esac
done

# Get the absolute path of the source vault
SOURCE_VAULT=$(realpath "$SOURCE_VAULT")

# Check if source vault exists
if [ ! -d "$SOURCE_VAULT" ]; then
    echo "Error: Source vault '$SOURCE_VAULT' does not exist."
    exit 1
fi

# Check if source vault has .obsidian directory
SOURCE_OBSIDIAN="$SOURCE_VAULT/.obsidian"
if [ ! -d "$SOURCE_OBSIDIAN" ]; then
    echo "Error: Source vault does not contain an .obsidian directory."
    exit 1
fi

# Function to create a new configuration file from template
create_config_file() {
    local config_file="$1"
    local config_dir=$(dirname "$config_file")
    
    # Create directory if it doesn't exist
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        echo "Created configuration directory: $config_dir"
    fi
    
    # Copy template if it exists, otherwise create a basic file
    if [ -f "vaults.conf.template" ]; then
        cp "vaults.conf.template" "$config_file"
        echo "Created configuration file from template: $config_file"
    else
        cat > "$config_file" << EOF
# Obsidian Vaults Configuration File
# List full paths to your Obsidian vaults, one per line.
# Lines starting with # are comments and will be ignored.

# Examples:
# /home/user/Documents/PersonalVault
# /home/user/Documents/WorkVault
# /Users/username/Obsidian/MainVault
# C:/Users/username/Documents/ObsidianVault

# Add your vault paths below:

EOF
        echo "Created new configuration file: $config_file"
    fi
    
    echo "Please edit this file to add your vault paths, then run the script again."
}

# Determine which configuration file to use
if [ -n "$CUSTOM_CONFIG_FILE" ]; then
    # Use custom config if provided
    CONFIG_FILE=$(realpath "$CUSTOM_CONFIG_FILE")
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Custom configuration file '$CUSTOM_CONFIG_FILE' does not exist."
        echo "Would you like to create it? (y/n): "
        read CREATE_CONF
        if [[ "$CREATE_CONF" =~ ^[Yy]$ ]]; then
            create_config_file "$CONFIG_FILE"
        fi
        exit 1
    fi
    
    echo "Using custom configuration file: $CONFIG_FILE"
else
    # Use default config
    CONFIG_FILE="$DEFAULT_CONFIG_FILE"
    
    # Check if default config exists, create if not
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Default configuration file not found."
        create_config_file "$CONFIG_FILE"
        exit 1
    fi
    
    echo "Using default configuration file: $CONFIG_FILE"
fi

# Check if the config file has any valid entries
VALID_ENTRIES=0
while IFS= read -r line || [ -n "$line" ]; do
    # Count non-empty, non-comment lines
    if [[ -n "$line" && ! "$line" =~ ^# ]]; then
        ((VALID_ENTRIES++))
    fi
done < "$CONFIG_FILE"

if [ $VALID_ENTRIES -eq 0 ]; then
    echo "Error: Configuration file '$CONFIG_FILE' does not contain any vault paths."
    echo "Please add at least one vault path to the file."
    exit 1
fi

# Display warning about destructive operation
echo "-------------------------------------"
echo "⚠️  WARNING: DESTRUCTIVE OPERATION ⚠️"
echo "-------------------------------------"
echo "This script will COMPLETELY REPLACE the .obsidian directory in destination vaults"
echo "with the one from: $SOURCE_VAULT"
echo ""
echo "All custom settings, plugins, themes, and workspace layouts in destination vaults will be overwritten."
echo "-------------------------------------"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "Running in DRY RUN mode. No changes will be made."
    echo ""
else
    # Ask for confirmation
    read -p "Do you want to proceed? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Count for synced and skipped vaults
SYNCED_COUNT=0
SKIPPED_COUNT=0

# Read vault paths and copy .obsidian to each one
while IFS= read -r vault_path || [ -n "$vault_path" ]; do
    # Skip empty lines and comments
    if [[ -z "$vault_path" || "$vault_path" =~ ^# ]]; then
        continue
    fi

    # Get the absolute path of the vault
    DEST_VAULT=$(realpath "$vault_path" 2>/dev/null)
    
    # Skip if realpath couldn't resolve the path
    if [ $? -ne 0 ]; then
        echo "✗ Warning: Could not resolve path '$DEST_VAULT'. Skipping."
        ((SKIPPED_COUNT++))
        continue
    fi

    # Skip if destination is the same as source
    if [ "$DEST_VAULT" = "$SOURCE_VAULT" ]; then
        echo "- Skipping: '$DEST_VAULT' (same as source vault)"
        ((SKIPPED_COUNT++))
        continue
    fi

    # Check if destination vault exists
    if [ ! -d "$DEST_VAULT" ]; then
        echo "✗ Warning: Destination vault '$DEST_VAULT' does not exist. Skipping."
        ((SKIPPED_COUNT++))
        continue
    fi

    # Check if destination has Obsidian structure
    DEST_OBSIDIAN="$DEST_VAULT/.obsidian"
    if [ ! -d "$DEST_OBSIDIAN" ]; then
        echo "✗ Warning: '$DEST_VAULT' does not appear to be an Obsidian vault (no .obsidian directory). Skipping."
        ((SKIPPED_COUNT++))
        continue
    fi

    if [ "$DRY_RUN" = true ]; then
        echo "Would sync Obsidian settings to: $DEST_VAULT"
        ((SYNCED_COUNT++))
    else
        # Remove existing .obsidian directory and copy the new one
        rm -rf "$DEST_OBSIDIAN"
        cp -r "$SOURCE_OBSIDIAN" "$DEST_VAULT/" 
        
        if [ $? -eq 0 ]; then
            echo "✓ Successfully synced settings to $DEST_VAULT"
            ((SYNCED_COUNT++))
        else
            echo "✗ Error: Failed to sync settings to '$DEST_VAULT'"
            ((SKIPPED_COUNT++))
        fi
    fi
done < "$CONFIG_FILE"

echo "-----------------------------------"
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN completed:"
    echo "✓ Would sync settings to $SYNCED_COUNT vaults"
    echo "✗ Would skip $SKIPPED_COUNT vaults"
else
    echo "Sync operation completed:"
    echo "✓ Settings synced to $SYNCED_COUNT vaults"
    echo "✗ Skipped $SKIPPED_COUNT vaults"
fi
