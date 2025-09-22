# `mulle-domain version`

Display version information for mulle-domain and its components.

## Synopsis

```bash
mulle-domain version [options]
```

## Description

The `version` command displays version information for mulle-domain and its dependencies. It can show detailed version information including build details, dependencies, and system information.

## Options

| Option | Description |
|--------|-------------|
| `--verbose` | Show detailed version information |
| `--json` | Output in JSON format |
| `--components` | Show component versions |
| `--dependencies` | Show dependency versions |
| `--system` | Show system information |
| `--help` | Display help information |

## Examples

### Basic Version Information

```bash
# Show basic version
mulle-domain version

# Show detailed version
mulle-domain version --verbose

# Show version in JSON format
mulle-domain version --json
```

### Component Information

```bash
# Show component versions
mulle-domain version --components

# Show dependency versions
mulle-domain version --dependencies

# Show system information
mulle-domain version --system
```

## Version Information

### Basic Output

```
mulle-domain version 1.2.3
```

### Verbose Output

```
mulle-domain Version Information
==============================

Core Version:
  mulle-domain: 1.2.3
  Build Date: 2024-01-15
  Build Time: 14:30:00 UTC
  Git Commit: abc123def456
  Git Branch: main

Components:
  mulle-env: 2.1.0
  mulle-sde: 3.0.1
  mulle-fetch: 1.5.2
  mulle-craft: 2.3.4

Dependencies:
  Foundation: 0.24.0
  MulleObjC: 0.18.1
  MulleFoundation: 0.23.0
  MulleContainer: 0.12.0

System:
  Platform: Linux
  Architecture: x86_64
  Kernel: 5.15.0-67-generic
  Distribution: Ubuntu 22.04.3 LTS
  Compiler: GCC 11.3.0
```

### JSON Output

```json
{
  "version": "1.2.3",
  "build": {
    "date": "2024-01-15",
    "time": "14:30:00 UTC",
    "commit": "abc123def456",
    "branch": "main"
  },
  "components": {
    "mulle-env": "2.1.0",
    "mulle-sde": "3.0.1",
    "mulle-fetch": "1.5.2",
    "mulle-craft": "2.3.4"
  },
  "dependencies": {
    "Foundation": "0.24.0",
    "MulleObjC": "0.18.1",
    "MulleFoundation": "0.23.0",
    "MulleContainer": "0.12.0"
  },
  "system": {
    "platform": "Linux",
    "architecture": "x86_64",
    "kernel": "5.15.0-67-generic",
    "distribution": "Ubuntu 22.04.3 LTS",
    "compiler": "GCC 11.3.0"
  }
}
```

## Version Components

### Core Version

- **Version Number**: Semantic version (major.minor.patch)
- **Build Date**: When the binary was built
- **Build Time**: Exact build timestamp
- **Git Commit**: Commit hash of the build
- **Git Branch**: Branch the build was made from

### Component Versions

- **mulle-env**: Environment management component
- **mulle-sde**: Build system component
- **mulle-fetch**: Dependency fetching component
- **mulle-craft**: Build execution component

### Dependency Versions

- **Foundation**: Core foundation library
- **MulleObjC**: Objective-C runtime
- **MulleFoundation**: Extended foundation functionality
- **MulleContainer**: Container data structures

### System Information

- **Platform**: Operating system
- **Architecture**: CPU architecture
- **Kernel**: Kernel version
- **Distribution**: Linux distribution (if applicable)
- **Compiler**: Compiler used for building

## Common Workflows

### Version Checking

```bash
# Quick version check
mulle-domain version

# Detailed version information
mulle-domain version --verbose

# Check for updates
mulle-domain version --verbose | grep -E "(version|commit)"
```

### Compatibility Verification

```bash
# Check component compatibility
mulle-domain version --components

# Verify dependency versions
mulle-domain version --dependencies

# System compatibility check
mulle-domain version --system
```

### Debugging

```bash
# Full diagnostic information
mulle-domain version --verbose --json

# Check build details
mulle-domain version --verbose | grep -A 5 "Build"

# Verify installation
mulle-domain version --system
```

## Integration

### With Build Scripts

```bash
#!/bin/bash
# Check version before build
VERSION=$(mulle-domain version)
echo "Building with mulle-domain $VERSION"

# Verify component versions
mulle-domain version --components | grep mulle-sde
if [ $? -ne 0 ]; then
    echo "mulle-sde not found"
    exit 1
fi
```

### With CI/CD

```yaml
# .github/workflows/build.yml
- name: Check Version
  run: |
    mulle-domain version --verbose
    mulle-domain version --json > version.json

- name: Verify Components
  run: |
    mulle-domain version --components
    if ! mulle-domain version --components | grep -q mulle-env; then
      echo "mulle-env component missing"
      exit 1
    fi
```

### With Development Scripts

```bash
#!/bin/bash
# Version comparison function
version_compare() {
    local current=$(mulle-domain version | cut -d' ' -f3)
    local required=$1

    if [ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" = "$required" ]; then
        echo "Version $current >= $required"
        return 0
    else
        echo "Version $current < $required"
        return 1
    fi
}

# Usage
version_compare "1.2.0"
```

## Troubleshooting

### Version Not Displayed

```bash
# Check if mulle-domain is installed
which mulle-domain

# Verify executable permissions
ls -la $(which mulle-domain)

# Try running directly
/path/to/mulle-domain version
```

### Incomplete Information

```bash
# Use verbose mode
mulle-domain version --verbose

# Check system information
mulle-domain version --system

# Verify installation integrity
mulle-domain version --json | python -m json.tool
```

### JSON Parsing Errors

```bash
# Validate JSON output
mulle-domain version --json | jq .

# Check for special characters
mulle-domain version --json | od -c

# Use python for validation
mulle-domain version --json | python -c "import sys, json; json.load(sys.stdin)"
```

### Component Missing

```bash
# Check component installation
mulle-domain version --components

# Verify PATH
echo $PATH | tr ':' '\n' | grep mulle

# Check component directories
ls -la /usr/local/lib/mulle-*/bin/
```

## Version Management

### Version Comparison

```bash
# Compare versions
current=$(mulle-domain version | cut -d' ' -f3)
latest=$(curl -s https://api.github.com/repos/mulle-core/mulle-domain/releases/latest | jq -r .tag_name)

if [ "$current" != "$latest" ]; then
    echo "Update available: $latest (current: $current)"
fi
```

### Version History

```bash
# Show version history
git log --oneline --grep="version" --grep="release"

# Check changelog
cat CHANGELOG.md | head -20

# Show git tags
git tag --sort=-version:refname | head -10
```

## Related Commands

- [`info`](info.md) - Show domain information
- [`status`](status.md) - Show current status
- [`update`](update.md) - Update mulle-domain
- [`upgrade`](upgrade.md) - Upgrade components