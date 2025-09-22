# `mulle-domain reset`

Reset domain environment to default state.

## Synopsis

```bash
mulle-domain reset [options]
```

## Description

The `reset` command restores the domain environment to its default state, removing all customizations and returning to a clean configuration. This is useful when the domain environment becomes corrupted or when you want to start fresh.

## Options

| Option | Description |
|--------|-------------|
| `--help` | Display help information |
| `--verbose` | Enable verbose output |
| `--force` | Reset without confirmation |
| `--keep-backup` | Keep backup of current state |

## Examples

### Basic Reset

```bash
# Reset domain environment
mulle-domain reset
```

### Force Reset

```bash
# Reset without confirmation prompt
mulle-domain reset --force
```

### Verbose Reset

```bash
# Show detailed reset progress
mulle-domain reset --verbose
```

### Reset with Backup

```bash
# Reset but keep backup of current state
mulle-domain reset --keep-backup
```

## What Gets Reset

When you run `mulle-domain reset`, the following are restored to defaults:

- **Active Domain**: Reset to default domain
- **Domain Settings**: All custom settings removed
- **Environment Variables**: All custom variables cleared
- **Domain Configuration**: Return to initial configuration
- **State Files**: Reset to clean state

## Common Workflows

### Troubleshooting Corrupted Environment

```bash
# Check current status
mulle-domain status

# Reset if problems detected
mulle-domain reset

# Reinitialize
mulle-domain init
```

### Starting Fresh

```bash
# Backup current state (optional)
mulle-domain backup "before-reset-$(date +%Y%m%d)"

# Reset environment
mulle-domain reset

# Set up fresh environment
mulle-domain domain create development
mulle-domain domain set development
```

### Development Environment Cleanup

```bash
# Reset development domain
mulle-domain domain set development
mulle-domain reset

# Configure clean development environment
mulle-domain settings set build-type Debug
mulle-domain environment set CC clang
```

## Reset vs Clean

### `reset`
- **Scope**: Resets entire domain environment
- **Effect**: Returns to default state
- **Use Case**: When environment is corrupted or needs fresh start
- **Data Loss**: Removes all customizations

### `clean`
- **Scope**: Cleans artifacts within current domain
- **Effect**: Removes build artifacts and temporary files
- **Use Case**: Clean up after builds or development
- **Data Loss**: Preserves settings and configuration

## Backup and Recovery

### Automatic Backup

```bash
# Reset with automatic backup
mulle-domain reset --keep-backup

# Backup is saved with timestamp
ls .mulle-domain/backups/
```

### Manual Backup

```bash
# Create manual backup before reset
mulle-domain backup "manual-backup"

# Reset environment
mulle-domain reset

# Restore if needed
mulle-domain restore manual-backup
```

## Troubleshooting

### Reset Fails

```bash
# Check permissions
ls -la .mulle-domain/

# Try with verbose output
mulle-domain reset --verbose

# Check disk space
df -h .
```

### Cannot Reset Active Domain

```bash
# Check current domain
mulle-domain status

# Switch to different domain first
mulle-domain domain set <other-domain>

# Then reset
mulle-domain reset
```

### Reset Doesn't Complete

```bash
# Kill any running processes
pkill -f mulle-domain

# Try force reset
mulle-domain reset --force

# Manual cleanup if needed
rm -rf .mulle-domain/state/
```

## Integration

### With Build Scripts

```bash
#!/bin/bash
# Reset environment for clean build
mulle-domain reset --force

# Configure build environment
mulle-domain settings set build-type Release
mulle-domain environment set CC gcc

# Build
make clean && make
```

### With CI/CD

```yaml
# .github/workflows/clean-build.yml
- name: Reset Domain Environment
  run: |
    mulle-domain reset --force
    mulle-domain init

- name: Configure Build
  run: |
    mulle-domain settings set build-type Release
    mulle-domain environment set CC clang
```

### With Development Workflows

```bash
# Reset for new feature branch
git checkout -b feature-x
mulle-domain reset
mulle-domain domain create feature-x
mulle-domain domain set feature-x

# Configure feature-specific settings
mulle-domain settings set feature-flag enabled
```

## Safety Considerations

### Data Loss Warning

```bash
# Always backup before reset
mulle-domain backup "backup-$(date +%Y%m%d-%H%M%S)"

# Confirm before reset
mulle-domain reset  # Will prompt for confirmation

# Or use force for automation
mulle-domain reset --force
```

### Selective Reset

```bash
# Reset specific components instead of everything
mulle-domain settings clear
mulle-domain environment clear

# Or reset specific domain
mulle-domain domain set <domain>
mulle-domain settings clear
```

## Related Commands

- [`init`](init.md) - Initialize domain environment
- [`clean`](clean.md) - Clean domain artifacts
- [`backup`](backup.md) - Backup domain configuration
- [`restore`](restore.md) - Restore domain configuration
- [`status`](status.md) - Show current status