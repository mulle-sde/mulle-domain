# `mulle-domain init`

Initialize a new domain environment for mulle-domain.

## Synopsis

```bash
mulle-domain init [options]
```

## Description

The `init` command initializes a new domain environment in the current directory. This creates the necessary directory structure and configuration files for managing domains with mulle-domain.

## Options

| Option | Description |
|--------|-------------|
| `--help` | Display help information |
| `--verbose` | Enable verbose output |
| `--dry-run` | Show what would be done without making changes |

## Examples

### Basic Initialization

```bash
# Initialize domain environment in current directory
mulle-domain init
```

### Verbose Initialization

```bash
# Initialize with detailed output
mulle-domain init --verbose
```

### Dry Run

```bash
# Preview what will be created
mulle-domain init --dry-run
```

## What Gets Created

When you run `mulle-domain init`, the following structure is created:

```
.mulle-domain/
├── config/
│   ├── domains/
│   └── settings.json
├── domains/
└── state/
    └── current
```

## Common Workflows

### New Project Setup

```bash
# Create new project directory
mkdir my-project
cd my-project

# Initialize domain environment
mulle-domain init

# Create first domain
mulle-domain domain create development
```

### Existing Project Integration

```bash
# Navigate to existing project
cd existing-project

# Initialize domain environment
mulle-domain init

# Import existing configuration
mulle-domain domain create production
```

## Troubleshooting

### Permission Denied

```bash
# Check directory permissions
ls -la

# Fix permissions if needed
chmod 755 .
```

### Directory Not Empty

```bash
# Check if .mulle-domain already exists
ls -la .mulle-domain/

# Remove existing configuration if desired
rm -rf .mulle-domain/
```

### Initialization Fails

```bash
# Run with verbose output for debugging
mulle-domain init --verbose

# Check system requirements
mulle-domain --version
```

## Integration

### With Build Systems

```bash
# Initialize domain environment
mulle-domain init

# Configure build settings
mulle-domain settings set build-type Release
mulle-domain settings set compiler clang
```

### With Version Control

```bash
# Initialize domain environment
mulle-domain init

# Add to version control (optional - configuration is usually local)
git add .mulle-domain/
git commit -m "Initialize domain environment"
```

## Related Commands

- [`domain`](domain.md) - Manage domains
- [`status`](status.md) - Show current status
- [`settings`](settings.md) - Configure settings