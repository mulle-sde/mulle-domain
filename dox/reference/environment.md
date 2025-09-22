# `mulle-domain environment`

Manage environment variables for domains.

## Synopsis

```bash
mulle-domain environment <subcommand> [options] [arguments]
```

## Description

The `environment` command manages environment variables that are set when a domain is active. These variables are automatically exported to the shell environment and can be used by build systems, scripts, and applications.

## Subcommands

### `list`

List all environment variables for the active domain.

```bash
mulle-domain environment list [options]
```

**Options:**
- `--verbose` - Show detailed variable information
- `--json` - Output in JSON format
- `--export` - Show as shell export commands

**Examples:**
```bash
# List all environment variables
mulle-domain environment list

# List with details
mulle-domain environment list --verbose

# Show as export commands
mulle-domain environment list --export
```

### `set <key> <value>`

Set an environment variable.

```bash
mulle-domain environment set <key> <value> [options]
```

**Options:**
- `--type <type>` - Specify variable type (string, path, boolean)
- `--export` - Export to shell immediately

**Examples:**
```bash
# Set compiler
mulle-domain environment set CC clang

# Set build flags
mulle-domain environment set CFLAGS "-O2 -g"

# Set path variable
mulle-domain environment set MY_PROJECT_PATH /path/to/project

# Set with export
mulle-domain environment set DEBUG 1 --export
```

### `get <key>`

Get the value of an environment variable.

```bash
mulle-domain environment get <key> [options]
```

**Options:**
- `--default <value>` - Return default value if variable not found

**Examples:**
```bash
# Get compiler setting
mulle-domain environment get CC

# Get with default
mulle-domain environment get BUILD_TYPE --default Debug
```

### `remove <key>`

Remove an environment variable.

```bash
mulle-domain environment remove <key> [options]
```

**Options:**
- `--force` - Remove without confirmation

**Examples:**
```bash
# Remove a variable
mulle-domain environment remove OLD_VAR

# Force remove
mulle-domain environment remove OLD_VAR --force
```

### `clear`

Clear all environment variables for the active domain.

```bash
mulle-domain environment clear [options]
```

**Options:**
- `--force` - Clear without confirmation

**Examples:**
```bash
# Clear all variables
mulle-domain environment clear

# Force clear
mulle-domain environment clear --force
```

## Common Environment Variables

### Build System Variables

```bash
# Compiler settings
mulle-domain environment set CC clang
mulle-domain environment set CXX clang++
mulle-domain environment set CFLAGS "-O2 -Wall"
mulle-domain environment set CXXFLAGS "-O2 -Wall -std=c++17"

# Build configuration
mulle-domain environment set CMAKE_BUILD_TYPE Release
mulle-domain environment set CMAKE_INSTALL_PREFIX /usr/local
mulle-domain environment set MAKEFLAGS "-j8"
```

### Development Variables

```bash
# Project paths
mulle-domain environment set PROJECT_ROOT /path/to/project
mulle-domain environment set BUILD_DIR ${PROJECT_ROOT}/build
mulle-domain environment set SOURCE_DIR ${PROJECT_ROOT}/src

# Development flags
mulle-domain environment set DEBUG 1
mulle-domain environment set VERBOSE 1
mulle-domain environment set LOG_LEVEL DEBUG
```

### Tool Configuration

```bash
# Editor and tools
mulle-domain environment set EDITOR vim
mulle-domain environment set VISUAL code
mulle-domain environment set PAGER less

# Version control
mulle-domain environment set GIT_AUTHOR_NAME "Your Name"
mulle-domain environment set GIT_AUTHOR_EMAIL "your.email@example.com"
```

## Variable Types

### String Variables

```bash
mulle-domain environment set BUILD_TYPE Release
mulle-domain environment set COMPILER clang
mulle-domain environment set ARCHITECTURE x86_64
```

### Path Variables

```bash
mulle-domain environment set PROJECT_ROOT /home/user/project
mulle-domain environment set INSTALL_PREFIX /usr/local
mulle-domain environment set LIBRARY_PATH /usr/local/lib
```

### Boolean Variables

```bash
mulle-domain environment set ENABLE_DEBUG true
mulle-domain environment set VERBOSE_BUILD false
mulle-domain environment set STRIP_SYMBOLS true
```

## Variable Expansion

Environment variables support expansion of other variables:

```bash
# Set base path
mulle-domain environment set PROJECT_ROOT /home/user/project

# Use in other variables
mulle-domain environment set BUILD_DIR ${PROJECT_ROOT}/build
mulle-domain environment set SOURCE_DIR ${PROJECT_ROOT}/src
mulle-domain environment set INSTALL_DIR ${PROJECT_ROOT}/install
```

## Common Workflows

### Development Environment

```bash
# Configure development environment
mulle-domain environment set CC clang
mulle-domain environment set CXX clang++
mulle-domain environment set CFLAGS "-O0 -g -Wall"
mulle-domain environment set CMAKE_BUILD_TYPE Debug

# List current environment
mulle-domain environment list --export
```

### Production Environment

```bash
# Configure production environment
mulle-domain environment set CC gcc
mulle-domain environment set CXX g++
mulle-domain environment set CFLAGS "-O3 -march=native"
mulle-domain environment set CMAKE_BUILD_TYPE Release
mulle-domain environment set MAKEFLAGS "-j$(nproc)"
```

### Cross-Platform Development

```bash
# Linux environment
mulle-domain environment set PLATFORM linux
mulle-domain environment set CC gcc
mulle-domain environment set PKG_CONFIG_PATH /usr/lib/pkgconfig

# macOS environment
mulle-domain environment set PLATFORM darwin
mulle-domain environment set CC clang
mulle-domain environment set SDKROOT /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
```

## Troubleshooting

### Variable Not Set

```bash
# Check current value
mulle-domain environment get <key>

# Verify variable was saved
mulle-domain environment list | grep <key>

# Check domain status
mulle-domain status
```

### Variable Not Expanded

```bash
# Check syntax (use curly braces)
mulle-domain environment set BUILD_DIR ${PROJECT_ROOT}/build

# Verify referenced variable exists
mulle-domain environment get PROJECT_ROOT
```

### Variables Not Exported

```bash
# Check if domain is active
mulle-domain status

# Manually export variables
eval "$(mulle-domain environment list --export)"

# Check shell environment
echo $CC
```

## Integration

### With Build Systems

```bash
# CMake integration
mulle-domain environment set CMAKE_GENERATOR "Unix Makefiles"
mulle-domain environment set CMAKE_BUILD_TYPE Release

# Make integration
mulle-domain environment set MAKEFLAGS "-j8"

# Autotools integration
mulle-domain environment set CFLAGS "-O2"
mulle-domain environment set LDFLAGS "-L/usr/local/lib"
```

### With Shell Scripts

```bash
#!/bin/bash
# Load domain environment
eval "$(mulle-domain environment list --export)"

# Use variables in script
echo "Building with $CC"
echo "Install prefix: $CMAKE_INSTALL_PREFIX"

$CC $CFLAGS -o myprogram main.c
```

### With Development Tools

```bash
# Configure editor
mulle-domain environment set EDITOR code
mulle-domain environment set VISUAL code

# Set language
mulle-domain environment set LANG en_US.UTF-8
mulle-domain environment set LC_ALL en_US.UTF-8

# Configure paths
mulle-domain environment set PATH "${HOME}/bin:${PATH}"
```

## Related Commands

- [`domain`](domain.md) - Manage domains
- [`settings`](settings.md) - Manage domain settings
- [`status`](status.md) - Show current status
- [`configure`](configure.md) - Configure domain settings