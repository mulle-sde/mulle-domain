# `mulle-domain clean`

Clean domain artifacts and temporary files.

## Synopsis

```bash
mulle-domain clean [options]
```

## Description

The `clean` command removes build artifacts, temporary files, and other generated content from the domain environment while preserving settings and configuration. This is useful for cleaning up after development work or preparing for fresh builds.

## Options

| Option | Description |
|--------|-------------|
| `--help` | Display help information |
| `--verbose` | Enable verbose output |
| `--dry-run` | Show what would be cleaned without removing |
| `--force` | Clean without confirmation |
| `--all` | Clean all domains, not just current |

## Examples

### Basic Clean

```bash
# Clean current domain
mulle-domain clean
```

### Verbose Clean

```bash
# Show detailed cleaning progress
mulle-domain clean --verbose
```

### Dry Run

```bash
# Preview what will be cleaned
mulle-domain clean --dry-run
```

### Clean All Domains

```bash
# Clean all domains
mulle-domain clean --all
```

## What Gets Cleaned

When you run `mulle-domain clean`, the following are removed:

- **Build Artifacts**: Object files, executables, libraries
- **Temporary Files**: Cache files, temporary configurations
- **Log Files**: Build logs and debug output
- **Generated Files**: Auto-generated source files
- **Cache Directories**: Compiler caches and intermediate files

## What Is Preserved

The following are NOT removed during cleaning:

- **Settings**: Domain settings and configuration
- **Environment Variables**: Custom environment variables
- **Domain Structure**: Domain directories and metadata
- **Source Files**: Original source code and assets
- **Backup Files**: Manual backups and archives

## Common Workflows

### Post-Build Cleanup

```bash
# After a build
make

# Clean build artifacts
mulle-domain clean

# Verify clean state
mulle-domain status
```

### Development Cleanup

```bash
# Clean before switching domains
mulle-domain clean

# Switch to different domain
mulle-domain domain set production

# Continue development
```

### CI/CD Cleanup

```bash
# Clean workspace
mulle-domain clean --force

# Fresh build
mulle-domain settings set build-type Release
make clean && make
```

## Clean vs Reset

### `clean`
- **Scope**: Removes artifacts within current domain
- **Effect**: Cleans temporary and generated files
- **Use Case**: Regular cleanup during development
- **Data Loss**: Minimal, preserves configuration

### `reset`
- **Scope**: Resets entire domain environment
- **Effect**: Returns to default state
- **Use Case**: When environment is corrupted
- **Data Loss**: Removes all customizations

## Selective Cleaning

### Clean Specific Types

```bash
# Clean only build artifacts
mulle-domain clean --build-only

# Clean only cache files
mulle-domain clean --cache-only

# Clean only log files
mulle-domain clean --logs-only
```

### Clean Specific Domains

```bash
# Clean specific domain
mulle-domain domain set development
mulle-domain clean

# Clean multiple domains
for domain in development staging production; do
    mulle-domain domain set $domain
    mulle-domain clean
done
```

## Troubleshooting

### Clean Fails

```bash
# Check permissions
ls -la .mulle-domain/

# Check for locked files
lsof .mulle-domain/

# Try with force
mulle-domain clean --force
```

### Files Not Removed

```bash
# Check file ownership
ls -l .mulle-domain/

# Check if files are in use
fuser .mulle-domain/

# Manual cleanup if needed
find .mulle-domain/ -name "*.tmp" -delete
```

### Clean Takes Too Long

```bash
# Use verbose to see progress
mulle-domain clean --verbose

# Clean specific large directories first
rm -rf .mulle-domain/cache/
mulle-domain clean
```

## Integration

### With Build Systems

```bash
# Make integration
make clean
mulle-domain clean

# CMake integration
rm -rf build/
mulle-domain clean

# Gradle/Maven integration
./gradlew clean
mulle-domain clean
```

### With Version Control

```bash
# Clean before commit
mulle-domain clean

# Check what would be committed
git status

# Commit clean state
git add .
git commit -m "Clean build artifacts"
```

### With Development Scripts

```bash
#!/bin/bash
# Development cleanup script
echo "Cleaning development environment..."

# Clean domain artifacts
mulle-domain clean --verbose

# Clean project artifacts
make clean
rm -rf *.log

echo "Cleanup complete"
```

## Performance Considerations

### Large Projects

```bash
# For large projects, clean incrementally
mulle-domain clean --build-only
mulle-domain clean --cache-only
mulle-domain clean --logs-only
```

### Frequent Cleaning

```bash
# Add to shell aliases
alias cleanall='mulle-domain clean && make clean'

# Use in build scripts
#!/bin/bash
trap 'mulle-domain clean' EXIT
# ... build commands ...
```

## Related Commands

- [`reset`](reset.md) - Reset domain to defaults
- [`backup`](backup.md) - Backup domain configuration
- [`status`](status.md) - Show current status
- [`init`](init.md) - Initialize domain environment