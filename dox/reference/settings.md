# `mulle-domain settings`

Manage domain-specific settings.

## Synopsis

```bash
mulle-domain settings <subcommand> [options] [arguments]
```

## Description

The `settings` command manages domain-specific configuration settings. Settings are key-value pairs that control various aspects of domain behavior and can be different for each domain.

## Subcommands

### `list`

List all current settings for the active domain.

```bash
mulle-domain settings list [options]
```

**Options:**
- `--verbose` - Show detailed setting information
- `--json` - Output in JSON format

**Examples:**
```bash
# List all settings
mulle-domain settings list

# List with details
mulle-domain settings list --verbose

# List in JSON format
mulle-domain settings list --json
```

### `set <key> <value>`

Set a setting value.

```bash
mulle-domain settings set <key> <value> [options]
```

**Options:**
- `--type <type>` - Specify value type (string, number, boolean)

**Examples:**
```bash
# Set compiler setting
mulle-domain settings set compiler clang

# Set build type
mulle-domain settings set build-type Release

# Set numeric value
mulle-domain settings set max-jobs 8

# Set boolean value
mulle-domain settings set verbose-build true
```

### `get <key>`

Get the value of a specific setting.

```bash
mulle-domain settings get <key> [options]
```

**Options:**
- `--default <value>` - Return default value if setting not found

**Examples:**
```bash
# Get compiler setting
mulle-domain settings get compiler

# Get with default
mulle-domain settings get build-type --default Debug
```

### `remove <key>`

Remove a setting.

```bash
mulle-domain settings remove <key> [options]
```

**Options:**
- `--force` - Remove without confirmation

**Examples:**
```bash
# Remove a setting
mulle-domain settings remove old-setting

# Force remove
mulle-domain settings remove old-setting --force
```

### `clear`

Clear all settings for the active domain.

```bash
mulle-domain settings clear [options]
```

**Options:**
- `--force` - Clear without confirmation

**Examples:**
```bash
# Clear all settings
mulle-domain settings clear

# Force clear
mulle-domain settings clear --force
```

## Common Settings

### Build Settings

```bash
# Compiler settings
mulle-domain settings set compiler clang
mulle-domain settings set compiler-version 14

# Build configuration
mulle-domain settings set build-type Debug
mulle-domain settings set optimization O2

# Parallel processing
mulle-domain settings set max-jobs 8
mulle-domain settings set parallel-build true
```

### Development Settings

```bash
# Code analysis
mulle-domain settings set enable-warnings true
mulle-domain settings set warning-level high

# Debugging
mulle-domain settings set debug-symbols true
mulle-domain settings set sanitize address

# Documentation
mulle-domain settings set generate-docs true
mulle-domain settings set doc-format html
```

### Environment Settings

```bash
# Paths
mulle-domain settings set install-prefix /usr/local
mulle-domain settings set build-dir build

# Tool versions
mulle-domain settings set cmake-version 3.28
mulle-domain settings set ninja-version 1.11
```

## Setting Types

### String Settings

```bash
mulle-domain settings set compiler clang
mulle-domain settings set build-type Release
mulle-domain settings set install-prefix /usr/local
```

### Numeric Settings

```bash
mulle-domain settings set max-jobs 8
mulle-domain settings set timeout 300
mulle-domain settings set buffer-size 4096
```

### Boolean Settings

```bash
mulle-domain settings set verbose-build true
mulle-domain settings set enable-warnings false
mulle-domain settings set parallel-build true
```

## Common Workflows

### Development Setup

```bash
# Configure development environment
mulle-domain settings set build-type Debug
mulle-domain settings set compiler clang
mulle-domain settings set enable-warnings true
mulle-domain settings set debug-symbols true

# List current settings
mulle-domain settings list --verbose
```

### Production Setup

```bash
# Configure production environment
mulle-domain settings set build-type Release
mulle-domain settings set optimization O3
mulle-domain settings set enable-warnings false
mulle-domain settings set strip-symbols true

# Performance settings
mulle-domain settings set max-jobs 16
mulle-domain settings set parallel-build true
```

### Cross-Platform Setup

```bash
# Linux settings
mulle-domain settings set platform linux
mulle-domain settings set compiler gcc
mulle-domain settings set linker ld

# macOS settings
mulle-domain settings set platform darwin
mulle-domain settings set compiler clang
mulle-domain settings set linker ld64

# Windows settings
mulle-domain settings set platform windows
mulle-domain settings set compiler msvc
mulle-domain settings set linker link
```

## Troubleshooting

### Setting Not Applied

```bash
# Check current value
mulle-domain settings get <key>

# Verify setting was saved
mulle-domain settings list | grep <key>

# Check domain status
mulle-domain status
```

### Invalid Setting Value

```bash
# Get help for valid values
mulle-domain settings --help

# Check setting type
mulle-domain settings get <key> --type

# Reset to default
mulle-domain settings remove <key>
```

### Settings Not Persisted

```bash
# Check write permissions
ls -la .mulle-domain/

# Verify domain is active
mulle-domain status

# Check disk space
df -h .
```

## Integration

### With Build Systems

```bash
# CMake integration
mulle-domain settings set CMAKE_BUILD_TYPE $(mulle-domain settings get build-type)
mulle-domain settings set CMAKE_INSTALL_PREFIX $(mulle-domain settings get install-prefix)

# Make integration
JOBS=$(mulle-domain settings get max-jobs)
make -j$JOBS
```

### With CI/CD

```yaml
# .github/workflows/build.yml
- name: Configure Build Settings
  run: |
    mulle-domain settings set build-type Release
    mulle-domain settings set compiler clang
    mulle-domain settings set max-jobs 2
```

### With Development Scripts

```bash
#!/bin/bash
# Load settings into environment
export CC=$(mulle-domain settings get compiler)
export CXX="${CC}++"
export CFLAGS="-O$(mulle-domain settings get optimization-level)"

# Build with configured settings
make
```

## Related Commands

- [`domain`](domain.md) - Manage domains
- [`environment`](environment.md) - Manage environment variables
- [`status`](status.md) - Show current status
- [`configure`](configure.md) - Configure domain settings