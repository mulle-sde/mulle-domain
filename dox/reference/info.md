# `mulle-domain info`

Display detailed information about domains.

## Synopsis

```bash
mulle-domain info [domain] [options]
```

## Description

The `info` command provides comprehensive information about domains, including configuration details, settings, environment variables, and system information. It can display information for a specific domain or all domains.

## Options

| Option | Description |
|--------|-------------|
| `--verbose` | Show detailed information |
| `--json` | Output in JSON format |
| `--settings` | Show only settings information |
| `--environment` | Show only environment variables |
| `--system` | Show system information |
| `--help` | Display help information |

## Examples

### Basic Domain Information

```bash
# Show info for current domain
mulle-domain info

# Show info for specific domain
mulle-domain info mydomain

# Show info for all domains
mulle-domain info --all
```

### Detailed Information

```bash
# Show verbose information
mulle-domain info mydomain --verbose

# Show settings only
mulle-domain info mydomain --settings

# Show environment variables only
mulle-domain info mydomain --environment
```

### System Information

```bash
# Show system information
mulle-domain info --system

# Show system info with domain context
mulle-domain info mydomain --system
```

## Information Categories

### Domain Metadata

- **Name**: Domain identifier
- **Description**: Domain description
- **Path**: Domain storage location
- **Created**: Creation timestamp
- **Modified**: Last modification timestamp
- **Status**: Active/inactive state

### Configuration Summary

- **Settings Count**: Number of domain settings
- **Environment Variables**: Number of environment variables
- **Templates Applied**: Applied configuration templates
- **Dependencies**: Domain dependencies

### System Integration

- **Active Domain**: Currently selected domain
- **Domain Path**: Base domain storage directory
- **Configuration Files**: Domain configuration files
- **Backup Status**: Available backups

## Output Formats

### Standard Output

```
Domain Information: development
==============================

Metadata:
  Name: development
  Description: Development environment
  Path: /home/user/project/.mulle-domain/domains/development
  Created: 2024-01-10 09:00:00
  Modified: 2024-01-15 10:30:00
  Status: active

Configuration:
  Settings: 12
  Environment Variables: 8
  Templates: development
  Dependencies: clang, cmake

System:
  Platform: linux
  Architecture: x86_64
  Domain Root: /home/user/project/.mulle-domain
  Active Domain: development
```

### Verbose Output

```
Domain Information: development (verbose)
========================================

Metadata:
  Name: development
  Description: Development environment for web application
  Path: /home/user/project/.mulle-domain/domains/development
  Created: 2024-01-10 09:00:00 UTC
  Modified: 2024-01-15 10:30:00 UTC
  Status: active
  Owner: development-team
  Tags: web, api, database

Configuration Details:
  Settings (12):
    compiler: clang
    build-type: Debug
    optimization: O0
    warnings: enabled
    debug-symbols: enabled

  Environment Variables (8):
    CC: clang
    CXX: clang++
    CFLAGS: -O0 -g -Wall
    CMAKE_BUILD_TYPE: Debug
    PROJECT_ROOT: /home/user/project

  Applied Templates:
    - development (base template)
    - web-development (extended)

  Dependencies:
    - clang (14.0.0)
    - cmake (3.28.0)
    - git (2.34.0)

System Integration:
  Platform: Linux (Ubuntu 22.04)
  Architecture: x86_64
  Kernel: 5.15.0-67-generic
  Domain Root: /home/user/project/.mulle-domain
  Active Domain: development
  Total Domains: 3
  Disk Usage: 45MB
```

### JSON Output

```json
{
  "domain": "development",
  "metadata": {
    "name": "development",
    "description": "Development environment",
    "path": "/home/user/project/.mulle-domain/domains/development",
    "created": "2024-01-10T09:00:00Z",
    "modified": "2024-01-15T10:30:00Z",
    "status": "active",
    "owner": "development-team",
    "tags": ["web", "api", "database"]
  },
  "configuration": {
    "settings_count": 12,
    "environment_count": 8,
    "templates": ["development", "web-development"],
    "dependencies": ["clang", "cmake", "git"]
  },
  "system": {
    "platform": "linux",
    "architecture": "x86_64",
    "domain_root": "/home/user/project/.mulle-domain",
    "active_domain": "development",
    "total_domains": 3
  }
}
```

## Common Workflows

### Domain Investigation

```bash
# Check domain status
mulle-domain info --verbose

# Investigate specific domain
mulle-domain info production --verbose

# Compare domain configurations
mulle-domain info development --json > dev.json
mulle-domain info production --json > prod.json
diff dev.json prod.json
```

### Troubleshooting

```bash
# Check for configuration issues
mulle-domain info --verbose | grep -i error

# Verify domain integrity
mulle-domain info mydomain --system

# Check resource usage
mulle-domain info --json | jq '.system.disk_usage'
```

### Monitoring

```bash
# Monitor domain changes
watch -n 30 'mulle-domain info --json | jq .metadata.modified'

# Check domain health
mulle-domain info --system | grep -E "(status|errors)"

# Audit domain configurations
for domain in $(mulle-domain domain list); do
    echo "=== $domain ==="
    mulle-domain info $domain --settings
done
```

## Integration

### With Monitoring Tools

```bash
# Nagios/Icinga check
#!/bin/bash
STATUS=$(mulle-domain info --json | jq -r '.metadata.status')
if [ "$STATUS" != "active" ]; then
    echo "CRITICAL: Domain not active"
    exit 2
fi
echo "OK: Domain is active"
exit 0
```

### With CI/CD Pipelines

```yaml
# .github/workflows/validate.yml
- name: Validate Domain Configuration
  run: |
    mulle-domain info --json | jq .
    if [ $? -ne 0 ]; then
      echo "Domain configuration invalid"
      exit 1
    fi
```

### With Development Scripts

```bash
#!/bin/bash
# Domain status check function
check_domain() {
    local domain=$1
    if mulle-domain info $domain --json > /dev/null 2>&1; then
        echo "Domain $domain is valid"
        return 0
    else
        echo "Domain $domain has issues"
        return 1
    fi
}

# Usage
check_domain development
```

## Troubleshooting

### No Information Displayed

```bash
# Check if domain exists
mulle-domain domain list

# Verify domain environment
ls -la .mulle-domain/

# Try with different options
mulle-domain info --system
```

### JSON Parsing Errors

```bash
# Validate JSON output
mulle-domain info --json | python -m json.tool

# Check for special characters
mulle-domain info --json | od -c

# Use jq for validation
mulle-domain info --json | jq .
```

### Permission Issues

```bash
# Check file permissions
ls -la .mulle-domain/
ls -la .mulle-domain/domains/

# Verify ownership
stat .mulle-domain/config/settings.json

# Fix permissions if needed
chmod 755 .mulle-domain/
chmod 644 .mulle-domain/config/*.json
```

### Performance Issues

```bash
# Use specific queries instead of verbose
mulle-domain info --settings  # Faster than --verbose

# Cache results for repeated queries
INFO=$(mulle-domain info --json)
echo $INFO | jq '.metadata.name'
```

## Related Commands

- [`status`](status.md) - Show current status
- [`domain`](domain.md) - Manage domains
- [`settings`](settings.md) - Manage domain settings
- [`environment`](environment.md) - Manage environment variables
- [`configure`](configure.md) - Configure domain settings