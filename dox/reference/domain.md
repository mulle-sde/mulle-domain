# `mulle-domain domain`

Manage domains within the mulle-domain environment.

## Synopsis

```bash
mulle-domain domain <subcommand> [options] [arguments]
```

## Description

The `domain` command provides subcommands for creating, listing, managing, and removing domains. Domains are isolated environments that can contain their own settings, environment variables, and configurations.

## Subcommands

### `create <name>`

Create a new domain with the specified name.

```bash
mulle-domain domain create <name> [options]
```

**Options:**
- `--description <text>` - Set domain description
- `--path <path>` - Set custom domain path
- `--template <template>` - Use domain template

**Examples:**
```bash
# Create basic domain
mulle-domain domain create development

# Create domain with description
mulle-domain domain create production --description "Production environment"

# Create domain with custom path
mulle-domain domain create staging --path /custom/staging/path
```

### `list`

List all available domains.

```bash
mulle-domain domain list [options]
```

**Options:**
- `--verbose` - Show detailed domain information
- `--json` - Output in JSON format

**Examples:**
```bash
# List all domains
mulle-domain domain list

# List with details
mulle-domain domain list --verbose

# List in JSON format
mulle-domain domain list --json
```

### `set <name>`

Set the specified domain as the active domain.

```bash
mulle-domain domain set <name> [options]
```

**Options:**
- `--force` - Force switch even if current domain has unsaved changes

**Examples:**
```bash
# Switch to development domain
mulle-domain domain set development

# Force switch to production
mulle-domain domain set production --force
```

### `remove <name>`

Remove the specified domain.

```bash
mulle-domain domain remove <name> [options]
```

**Options:**
- `--force` - Force removal without confirmation
- `--keep-files` - Keep domain files but remove from registry

**Examples:**
```bash
# Remove domain with confirmation
mulle-domain domain remove olddomain

# Force remove without confirmation
mulle-domain domain remove olddomain --force
```

### `info <name>`

Show detailed information about a specific domain.

```bash
mulle-domain domain info <name> [options]
```

**Options:**
- `--json` - Output in JSON format

**Examples:**
```bash
# Show domain information
mulle-domain domain info development

# Show in JSON format
mulle-domain domain info development --json
```

## Common Workflows

### Domain Lifecycle

```bash
# Create new domain
mulle-domain domain create feature-branch

# Switch to the new domain
mulle-domain domain set feature-branch

# Configure domain settings
mulle-domain settings set compiler clang
mulle-domain environment set DEBUG 1

# Work with the domain
# ... development work ...

# Switch back to main domain
mulle-domain domain set development

# Remove feature domain when done
mulle-domain domain remove feature-branch
```

### Environment Management

```bash
# Create separate domains for different environments
mulle-domain domain create development
mulle-domain domain create staging
mulle-domain domain create production

# Configure each domain differently
mulle-domain domain set development
mulle-domain settings set build-type Debug
mulle-domain environment set LOG_LEVEL DEBUG

mulle-domain domain set staging
mulle-domain settings set build-type Release
mulle-domain environment set LOG_LEVEL INFO

mulle-domain domain set production
mulle-domain settings set build-type Release
mulle-domain environment set LOG_LEVEL ERROR
```

## Domain Concepts

### Domain Isolation

Each domain maintains its own:
- Settings and configuration
- Environment variables
- File paths and locations
- Build configurations

### Active Domain

The active domain is the one currently being used. Commands that don't specify a domain operate on the active domain.

### Domain Storage

Domains are stored in the `.mulle-domain/domains/` directory by default, but can be configured to use custom paths.

## Troubleshooting

### Domain Not Found

```bash
# Check available domains
mulle-domain domain list

# Verify domain name spelling
mulle-domain domain list --verbose
```

### Cannot Switch Domains

```bash
# Check current domain status
mulle-domain status

# Force switch if needed
mulle-domain domain set <name> --force
```

### Domain Creation Fails

```bash
# Check permissions
ls -la .mulle-domain/

# Check available disk space
df -h .

# Try with verbose output
mulle-domain domain create <name> --verbose
```

### Domain Removal Issues

```bash
# Check if domain is currently active
mulle-domain status

# Switch to different domain first
mulle-domain domain set <other-domain>

# Then remove
mulle-domain domain remove <name>
```

## Integration

### With Build Systems

```bash
# Create domain-specific build configurations
mulle-domain domain create debug-build
mulle-domain domain set debug-build
mulle-domain settings set build-type Debug
mulle-domain environment set CMAKE_BUILD_TYPE Debug

mulle-domain domain create release-build
mulle-domain domain set release-build
mulle-domain settings set build-type Release
mulle-domain environment set CMAKE_BUILD_TYPE Release
```

### With Version Control

```bash
# Create domain for feature branch
git checkout -b feature-x
mulle-domain domain create feature-x
mulle-domain domain set feature-x

# Configure feature-specific settings
mulle-domain settings set feature-flag enabled

# When merging, switch back
git checkout main
mulle-domain domain set development
```

## Related Commands

- [`init`](init.md) - Initialize domain environment
- [`status`](status.md) - Show current domain status
- [`settings`](settings.md) - Manage domain settings
- [`environment`](environment.md) - Manage environment variables