# `mulle-domain status`

Display the current status of the domain environment.

## Synopsis

```bash
mulle-domain status [options]
```

## Description

The `status` command shows the current state of the domain environment, including the active domain, available domains, and configuration information.

## Options

| Option | Description |
|--------|-------------|
| `--verbose` | Show detailed status information |
| `--json` | Output status in JSON format |
| `--help` | Display help information |

## Examples

### Basic Status

```bash
# Show current status
mulle-domain status
```

### Verbose Status

```bash
# Show detailed status information
mulle-domain status --verbose
```

### JSON Output

```bash
# Get status in JSON format
mulle-domain status --json
```

## Status Information

The status command displays:

- **Active Domain**: Currently selected domain
- **Available Domains**: List of all configured domains
- **Domain Path**: Location of domain files
- **Configuration Status**: Settings and environment state
- **Last Modified**: When the domain was last changed

## Common Workflows

### Daily Check

```bash
# Quick status check
mulle-domain status

# Detailed status with verbose
mulle-domain status --verbose
```

### Troubleshooting

```bash
# Check status when having issues
mulle-domain status --verbose

# Verify domain configuration
mulle-domain status --json | jq .
```

### Automation

```bash
# Check status in scripts
if mulle-domain status --json | jq -e '.active_domain' > /dev/null; then
    echo "Domain environment is active"
else
    echo "No active domain"
fi
```

## Output Format

### Standard Output

```
Active Domain: development
Available Domains: development, staging, production
Domain Path: /home/user/project/.mulle-domain
Configuration: 12 settings, 8 environment variables
Last Modified: 2024-01-15 10:30:00
```

### Verbose Output

```
Domain Environment Status
========================

Active Domain:
  Name: development
  Path: /home/user/project/.mulle-domain/domains/development
  Description: Development environment
  Created: 2024-01-10 09:00:00
  Modified: 2024-01-15 10:30:00

Available Domains:
  development (active)
    Path: /home/user/project/.mulle-domain/domains/development
    Settings: 12
    Environment: 8

  staging
    Path: /home/user/project/.mulle-domain/domains/staging
    Settings: 8
    Environment: 6

  production
    Path: /home/user/project/.mulle-domain/domains/production
    Settings: 15
    Environment: 12

Configuration Summary:
  Total Domains: 3
  Total Settings: 35
  Total Environment Variables: 26
  Domain Storage: /home/user/project/.mulle-domain
```

### JSON Output

```json
{
  "active_domain": "development",
  "available_domains": [
    {
      "name": "development",
      "path": "/home/user/project/.mulle-domain/domains/development",
      "settings_count": 12,
      "environment_count": 8,
      "active": true
    },
    {
      "name": "staging",
      "path": "/home/user/project/.mulle-domain/domains/staging",
      "settings_count": 8,
      "environment_count": 6,
      "active": false
    }
  ],
  "domain_path": "/home/user/project/.mulle-domain",
  "total_settings": 35,
  "total_environment_variables": 26,
  "last_modified": "2024-01-15T10:30:00Z"
}
```

## Troubleshooting

### No Active Domain

```bash
# Check if domain environment exists
ls -la .mulle-domain/

# Initialize if missing
mulle-domain init

# Create and set active domain
mulle-domain domain create development
mulle-domain domain set development
```

### Status Shows Errors

```bash
# Check domain files
ls -la .mulle-domain/domains/

# Verify configuration files
cat .mulle-domain/config/settings.json

# Reset if corrupted
mulle-domain reset
```

### JSON Parsing Issues

```bash
# Validate JSON output
mulle-domain status --json | python -m json.tool

# Check for special characters
mulle-domain status --json | hexdump -C
```

## Integration

### With Build Scripts

```bash
#!/bin/bash
# Check domain status before build
if ! mulle-domain status --json | jq -e '.active_domain' > /dev/null; then
    echo "No active domain. Please run 'mulle-domain domain set <name>'"
    exit 1
fi

DOMAIN=$(mulle-domain status --json | jq -r '.active_domain')
echo "Building with domain: $DOMAIN"
```

### With CI/CD

```yaml
# .github/workflows/build.yml
- name: Check Domain Status
  run: |
    mulle-domain status --verbose
    if [ $? -ne 0 ]; then
      echo "Domain environment not properly configured"
      exit 1
    fi
```

### With Development Tools

```bash
# Show status in shell prompt
PS1="$(mulle-domain status --json | jq -r '.active_domain') $PS1"

# Quick status check function
domain_status() {
    mulle-domain status --verbose
}
```

## Related Commands

- [`init`](init.md) - Initialize domain environment
- [`domain`](domain.md) - Manage domains
- [`settings`](settings.md) - Manage domain settings
- [`environment`](environment.md) - Manage environment variables