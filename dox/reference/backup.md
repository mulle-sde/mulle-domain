# `mulle-domain backup`

Create backups of domain configurations and data.

## Synopsis

```bash
mulle-domain backup [name] [options]
```

## Description

The `backup` command creates compressed archives of domain configurations, settings, environment variables, and other important data. Backups can be used to restore domains to previous states or migrate configurations between systems.

## Options

| Option | Description |
|--------|-------------|
| `--list` | List available backups |
| `--delete <name>` | Delete a specific backup |
| `--clean` | Remove old backups |
| `--path <path>` | Specify backup destination |
| `--compress <level>` | Set compression level (1-9) |
| `--include-data` | Include domain data files |
| `--exclude-logs` | Exclude log files from backup |
| `--help` | Display help information |

## Examples

### Basic Backup

```bash
# Backup current domain
mulle-domain backup

# Backup with custom name
mulle-domain backup "my-backup-$(date +%Y%m%d)"

# Backup specific domain
mulle-domain domain set production
mulle-domain backup production-backup
```

### Backup Management

```bash
# List all backups
mulle-domain backup --list

# Delete old backup
mulle-domain backup --delete old-backup

# Clean old backups (keep last 5)
mulle-domain backup --clean
```

### Advanced Backup

```bash
# Backup with high compression
mulle-domain backup --compress 9

# Backup to specific location
mulle-domain backup --path /mnt/backup/

# Backup including data files
mulle-domain backup --include-data

# Backup excluding logs
mulle-domain backup --exclude-logs
```

## Backup Contents

### Default Backup Includes

- **Domain Configuration**: Settings and metadata
- **Environment Variables**: Custom environment variables
- **Domain Templates**: Applied configuration templates
- **Domain State**: Current domain status and settings

### Optional Backup Includes

- **Domain Data**: User data files (when `--include-data` is used)
- **Log Files**: Application and system logs
- **Cache Files**: Cached data and temporary files
- **Custom Files**: User-specified additional files

### Backup Exclusions

- **System Files**: OS and system-specific files
- **Temporary Files**: Runtime temporary files
- **Lock Files**: Process lock files
- **Socket Files**: Unix domain sockets

## Backup Storage

### Default Location

```
~/.mulle-domain/backups/
├── domain-name-20240115-143000.tar.gz
├── domain-name-20240116-091500.tar.gz
└── domain-name-20240117-162000.tar.gz
```

### Custom Location

```bash
# Backup to external drive
mulle-domain backup --path /mnt/external/backup/

# Backup to network share
mulle-domain backup --path /net/backup/server/

# Backup to cloud storage mount
mulle-domain backup --path /mnt/cloud/backup/
```

## Backup Naming

### Automatic Naming

```
domain-name-YYYYMMDD-HHMMSS.tar.gz
```

- **domain-name**: Name of the backed up domain
- **YYYYMMDD**: Date in ISO format
- **HHMMSS**: Time in 24-hour format

### Custom Naming

```bash
# Descriptive names
mulle-domain backup "before-major-changes"
mulle-domain backup "production-v2.1.0"
mulle-domain backup "staging-migration"

# Timestamped names
mulle-domain backup "backup-$(date +%Y%m%d-%H%M%S)"
mulle-domain backup "weekly-$(date +%U)"
```

## Compression Options

### Compression Levels

```bash
# Fast compression (level 1)
mulle-domain backup --compress 1

# Balanced compression (level 6, default)
mulle-domain backup --compress 6

# Maximum compression (level 9)
mulle-domain backup --compress 9
```

### Compression Trade-offs

| Level | Speed | Size | Use Case |
|-------|-------|------|----------|
| 1 | Fastest | Largest | Quick backups |
| 6 | Balanced | Medium | Default choice |
| 9 | Slowest | Smallest | Archive storage |

## Backup Management

### Listing Backups

```bash
# List all backups
mulle-domain backup --list

# List backups for specific domain
mulle-domain backup --list production

# List with details
mulle-domain backup --list --verbose
```

### Deleting Backups

```bash
# Delete specific backup
mulle-domain backup --delete production-20240115-143000

# Delete multiple backups
mulle-domain backup --delete production-20240115-*
```

### Cleaning Backups

```bash
# Keep only last 5 backups
mulle-domain backup --clean --keep 5

# Clean backups older than 30 days
mulle-domain backup --clean --older-than 30d

# Clean backups larger than 100MB
mulle-domain backup --clean --larger-than 100MB
```

## Common Workflows

### Regular Backup Schedule

```bash
#!/bin/bash
# Daily backup script
DOMAIN="production"
BACKUP_NAME="${DOMAIN}-$(date +%Y%m%d-%H%M%S)"

mulle-domain domain set $DOMAIN
mulle-domain backup $BACKUP_NAME

# Clean old backups (keep last 7)
mulle-domain backup --clean --keep 7
```

### Pre-Deployment Backup

```bash
# Backup before deployment
mulle-domain backup "pre-deploy-$(date +%Y%m%d)"

# Deploy changes
# ... deployment commands ...

# Verify deployment
mulle-domain status

# Create post-deployment backup
mulle-domain backup "post-deploy-$(date +%Y%m%d)"
```

### Migration Backup

```bash
# Backup source system
mulle-domain backup "migration-source-$(date +%Y%m%d)"

# Transfer backup to destination
scp ~/.mulle-domain/backups/* user@destination:/tmp/

# Restore on destination
# ... restore commands ...
```

## Integration

### With Cron Jobs

```bash
# Add to crontab for daily backups
0 2 * * * /usr/local/bin/mulle-domain backup "daily-$(date +\\%Y\\%m\\%d)"

# Weekly cleanup
0 3 * * 0 /usr/local/bin/mulle-domain backup --clean --keep 7
```

### With CI/CD Pipelines

```yaml
# .github/workflows/backup.yml
name: Domain Backup
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Create Backup
        run: |
          mulle-domain backup "ci-$(date +%Y%m%d)"
          mulle-domain backup --clean --keep 30
```

### With Monitoring Systems

```bash
#!/bin/bash
# Backup monitoring script
BACKUP_RESULT=$(mulle-domain backup "monitor-$(date +%Y%m%d)" 2>&1)
BACKUP_STATUS=$?

if [ $BACKUP_STATUS -eq 0 ]; then
    echo "Backup successful"
    # Send success notification
else
    echo "Backup failed: $BACKUP_RESULT"
    # Send failure notification
fi
```

## Troubleshooting

### Backup Fails

```bash
# Check disk space
df -h ~/.mulle-domain/

# Check permissions
ls -la ~/.mulle-domain/backups/

# Try with verbose output
mulle-domain backup --verbose
```

### Backup Too Large

```bash
# Exclude unnecessary files
mulle-domain backup --exclude-logs --exclude-cache

# Use higher compression
mulle-domain backup --compress 9

# Split large backups
mulle-domain backup large-backup --split-size 1GB
```

### Permission Issues

```bash
# Fix backup directory permissions
chmod 755 ~/.mulle-domain/backups/

# Change ownership
chown -R $USER ~/.mulle-domain/backups/

# Use sudo if necessary
sudo mulle-domain backup
```

### Network Backup Issues

```bash
# Test network connectivity
ping backup-server

# Check mount point
ls -la /mnt/backup/

# Use rsync for large backups
rsync -av ~/.mulle-domain/ /mnt/backup/
```

## Backup Verification

### Verify Backup Integrity

```bash
# List backup contents
tar -tzf backup.tar.gz | head -20

# Verify backup size
ls -lh backup.tar.gz

# Test backup extraction
tar -tzf backup.tar.gz > /dev/null
```

### Automated Verification

```bash
#!/bin/bash
# Backup verification script
BACKUP_FILE=$1

if tar -tzf $BACKUP_FILE > /dev/null 2>&1; then
    echo "Backup $BACKUP_FILE is valid"
    exit 0
else
    echo "Backup $BACKUP_FILE is corrupted"
    exit 1
fi
```

## Security Considerations

### Backup Encryption

```bash
# Encrypt backup with GPG
mulle-domain backup | gpg -c > encrypted-backup.tar.gz.gpg

# Decrypt backup
gpg -d encrypted-backup.tar.gz.gpg | tar xzf -
```

### Access Control

```bash
# Secure backup directory
chmod 700 ~/.mulle-domain/backups/

# Use backup user
sudo -u backup-user mulle-domain backup
```

## Related Commands

- [`restore`](restore.md) - Restore domain from backup
- [`clean`](clean.md) - Clean domain artifacts
- [`reset`](reset.md) - Reset domain to defaults
- [`status`](status.md) - Show current status