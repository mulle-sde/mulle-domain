# `mulle-domain restore`

Restore domain configurations from backups.

## Synopsis

```bash
mulle-domain restore <backup-name> [options]
```

## Description

The `restore` command restores domain configurations and data from previously created backups. This allows you to recover domains to previous states, migrate configurations between systems, or rollback changes.

## Options

| Option | Description |
|--------|-------------|
| `--list` | List available backups for restoration |
| `--preview` | Show what will be restored without restoring |
| `--force` | Restore without confirmation |
| `--partial` | Restore only specific components |
| `--path <path>` | Specify backup source path |
| `--target <domain>` | Restore to different domain name |
| `--help` | Display help information |

## Examples

### Basic Restore

```bash
# Restore from backup
mulle-domain restore production-20240115-143000

# Restore latest backup
mulle-domain restore $(mulle-domain backup --list | tail -1)

# Restore with confirmation
mulle-domain restore my-backup
```

### Preview and Verify

```bash
# Preview restore contents
mulle-domain restore my-backup --preview

# List available backups
mulle-domain restore --list

# Check backup integrity
mulle-domain restore my-backup --verify
```

### Advanced Restore

```bash
# Restore to different domain
mulle-domain restore my-backup --target new-domain

# Partial restore (settings only)
mulle-domain restore my-backup --partial settings

# Restore from custom path
mulle-domain restore my-backup --path /mnt/backup/
```

## Restore Process

### Pre-Restore Checks

1. **Backup Verification**: Validates backup integrity
2. **Space Check**: Ensures sufficient disk space
3. **Permission Check**: Verifies write permissions
4. **Conflict Detection**: Identifies potential conflicts

### Restore Steps

1. **Extract Backup**: Uncompresses backup archive
2. **Validate Contents**: Checks backup structure
3. **Apply Configuration**: Restores settings and variables
4. **Update State**: Refreshes domain state
5. **Verify Restore**: Confirms successful restoration

### Post-Restore Actions

1. **Domain Activation**: Sets restored domain as active
2. **Service Restart**: Restarts dependent services
3. **Configuration Reload**: Reloads configuration files
4. **Verification**: Runs integrity checks

## Restore Types

### Full Restore

```bash
# Complete domain restoration
mulle-domain restore production-backup

# Includes:
# - Domain configuration
# - Environment variables
# - Settings and preferences
# - Domain state and metadata
```

### Partial Restore

```bash
# Restore only settings
mulle-domain restore my-backup --partial settings

# Restore only environment variables
mulle-domain restore my-backup --partial environment

# Restore only domain metadata
mulle-domain restore my-backup --partial metadata
```

### Selective Restore

```bash
# Restore specific settings
mulle-domain restore my-backup --include compiler,build-type

# Exclude certain components
mulle-domain restore my-backup --exclude logs,cache

# Restore to different location
mulle-domain restore my-backup --target restored-domain
```

## Backup Sources

### Local Backups

```bash
# Restore from default location
mulle-domain restore my-backup

# Restore from custom local path
mulle-domain restore my-backup --path /home/user/backups/

# Restore from external drive
mulle-domain restore my-backup --path /mnt/external/
```

### Remote Backups

```bash
# Restore from network share
mulle-domain restore my-backup --path //server/backup/

# Restore from cloud storage
mulle-domain restore my-backup --path s3://my-bucket/backups/

# Restore from HTTP source
mulle-domain restore my-backup --path https://backup.example.com/
```

## Conflict Resolution

### Configuration Conflicts

```bash
# Handle existing domain
mulle-domain restore my-backup --conflict rename  # Rename existing
mulle-domain restore my-backup --conflict overwrite  # Overwrite existing
mulle-domain restore my-backup --conflict skip  # Skip conflicting items
```

### File Conflicts

```bash
# File conflict resolution
mulle-domain restore my-backup --on-conflict backup  # Backup existing files
mulle-domain restore my-backup --on-conflict overwrite  # Overwrite files
mulle-domain restore my-backup --on-conflict skip  # Skip conflicting files
```

## Common Workflows

### Disaster Recovery

```bash
# Emergency restore procedure
mulle-domain restore production-backup --force
mulle-domain status
mulle-domain info --verbose
```

### Migration Restore

```bash
# Restore on new system
mulle-domain init
mulle-domain restore migration-backup --target production
mulle-domain domain set production
```

### Rollback Restore

```bash
# Rollback failed changes
mulle-domain backup "before-failed-changes"
# ... make changes that fail ...
mulle-domain restore "before-failed-changes" --force
```

### Development Restore

```bash
# Restore clean development state
mulle-domain restore development-clean --target development-temp
mulle-domain domain set development-temp
# ... development work ...
```

## Verification and Testing

### Restore Verification

```bash
# Verify restore integrity
mulle-domain restore my-backup --verify

# Check restored configuration
mulle-domain info restored-domain --verbose

# Test restored functionality
mulle-domain status
```

### Automated Testing

```bash
#!/bin/bash
# Restore testing script
BACKUP_NAME=$1
TEMP_DOMAIN="test-restore-$(date +%s)"

# Restore to temporary domain
mulle-domain restore $BACKUP_NAME --target $TEMP_DOMAIN

# Verify restore
if mulle-domain info $TEMP_DOMAIN > /dev/null; then
    echo "Restore successful"
    # Cleanup
    mulle-domain domain remove $TEMP_DOMAIN
else
    echo "Restore failed"
    exit 1
fi
```

## Troubleshooting

### Restore Fails

```bash
# Check backup exists
mulle-domain restore --list | grep my-backup

# Verify backup integrity
tar -tzf ~/.mulle-domain/backups/my-backup.tar.gz

# Check permissions
ls -la ~/.mulle-domain/backups/
```

### Insufficient Space

```bash
# Check available space
df -h ~/.mulle-domain/

# Check backup size
ls -lh ~/.mulle-domain/backups/my-backup.tar.gz

# Free up space
mulle-domain clean --all
```

### Permission Issues

```bash
# Fix permissions
chmod 755 ~/.mulle-domain/
chmod 644 ~/.mulle-domain/backups/*.tar.gz

# Use sudo if necessary
sudo mulle-domain restore my-backup
```

### Corrupted Backup

```bash
# Test backup integrity
tar -tzf ~/.mulle-domain/backups/my-backup.tar.gz > /dev/null

# Try alternative backup
mulle-domain restore --list
mulle-domain restore alternative-backup
```

## Integration

### With Monitoring Systems

```bash
#!/bin/bash
# Restore monitoring
RESTORE_START=$(date +%s)
mulle-domain restore production-backup
RESTORE_END=$(date +%s)

DURATION=$((RESTORE_END - RESTORE_START))
echo "Restore completed in ${DURATION}s"

# Send metrics to monitoring system
# curl -X POST monitoring.example.com/metrics \
#   -d "restore_duration=${DURATION}"
```

### With CI/CD Pipelines

```yaml
# .github/workflows/restore.yml
name: Domain Restore
on:
  workflow_dispatch:
    inputs:
      backup_name:
        required: true

jobs:
  restore:
    runs-on: ubuntu-latest
    steps:
      - name: Restore Domain
        run: |
          mulle-domain restore ${{ inputs.backup_name }}
          mulle-domain status
```

### With Backup Scripts

```bash
#!/bin/bash
# Automated backup and restore test
BACKUP_NAME="test-$(date +%Y%m%d-%H%M%S)"

# Create backup
mulle-domain backup $BACKUP_NAME

# Test restore
mulle-domain restore $BACKUP_NAME --target test-domain

# Verify
if mulle-domain info test-domain > /dev/null; then
    echo "Backup and restore test passed"
    mulle-domain domain remove test-domain
else
    echo "Backup and restore test failed"
    exit 1
fi
```

## Security Considerations

### Backup Encryption

```bash
# Restore encrypted backup
gpg -d ~/.mulle-domain/backups/encrypted-backup.tar.gz.gpg | \
  mulle-domain restore - --target restored-domain
```

### Access Control

```bash
# Restore with specific user
sudo -u domain-user mulle-domain restore production-backup

# Verify restore permissions
ls -la ~/.mulle-domain/domains/restored-domain/
```

### Audit Logging

```bash
# Log restore operations
echo "$(date): User $USER restored $BACKUP_NAME to $TARGET_DOMAIN" >> /var/log/domain-restore.log

# Audit restored files
find ~/.mulle-domain/domains/restored-domain/ -type f -newer ~/.mulle-domain/backups/$BACKUP_NAME.tar.gz
```

## Performance Considerations

### Large Backups

```bash
# Monitor restore progress
mulle-domain restore large-backup --verbose

# Parallel extraction (if supported)
mulle-domain restore large-backup --parallel

# Incremental restore
mulle-domain restore large-backup --incremental
```

### Network Restores

```bash
# Optimize network transfer
mulle-domain restore remote-backup --compress none

# Resume interrupted restore
mulle-domain restore remote-backup --resume
```

## Related Commands

- [`backup`](backup.md) - Create domain backups
- [`clean`](clean.md) - Clean domain artifacts
- [`reset`](reset.md) - Reset domain to defaults
- [`status`](status.md) - Show current status
- [`info`](info.md) - Show domain information