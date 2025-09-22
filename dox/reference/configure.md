# `mulle-domain configure`

Configure domain settings and properties.

## Synopsis

```bash
mulle-domain configure <domain> [options]
```

## Description

The `configure` command allows you to modify domain-specific settings and properties. This includes domain metadata, paths, templates, and other configuration options that affect how the domain operates.

## Options

| Option | Description |
|--------|-------------|
| `--description <text>` | Set domain description |
| `--path <path>` | Set custom domain path |
| `--template <template>` | Apply domain template |
| `--enable-ssl` | Enable SSL/TLS configuration |
| `--disable-ssl` | Disable SSL/TLS configuration |
| `--verbose` | Enable verbose output |
| `--help` | Display help information |

## Examples

### Basic Configuration

```bash
# Configure domain with description
mulle-domain configure mydomain --description "My development domain"

# Configure domain with custom path
mulle-domain configure staging --path /custom/staging/path

# Configure domain with template
mulle-domain configure production --template production
```

### SSL Configuration

```bash
# Enable SSL for domain
mulle-domain configure mydomain --enable-ssl

# Disable SSL for domain
mulle-domain configure mydomain --disable-ssl
```

### Template-Based Configuration

```bash
# Apply development template
mulle-domain configure development --template development

# Apply production template
mulle-domain configure production --template production

# Apply custom template
mulle-domain configure custom --template my-custom-template
```

## Configuration Options

### Domain Metadata

```bash
# Set domain description
mulle-domain configure mydomain --description "Web application domain"

# Set domain owner
mulle-domain configure mydomain --owner "development-team"

# Set domain tags
mulle-domain configure mydomain --tags "web,api,database"
```

### Path Configuration

```bash
# Set custom domain storage path
mulle-domain configure mydomain --path /opt/domains/mydomain

# Set working directory
mulle-domain configure mydomain --workdir /home/user/projects

# Set log directory
mulle-domain configure mydomain --logdir /var/log/domains/mydomain
```

### Network Configuration

```bash
# Configure domain ports
mulle-domain configure mydomain --http-port 8080 --https-port 8443

# Configure domain hostname
mulle-domain configure mydomain --hostname mydomain.example.com

# Configure SSL certificates
mulle-domain configure mydomain --ssl-cert /path/to/cert.pem --ssl-key /path/to/key.pem
```

### Resource Configuration

```bash
# Configure memory limits
mulle-domain configure mydomain --memory-limit 2GB

# Configure CPU limits
mulle-domain configure mydomain --cpu-limit 4

# Configure storage limits
mulle-domain configure mydomain --storage-limit 100GB
```

## Templates

### Built-in Templates

**Development Template:**
```bash
mulle-domain configure dev --template development
# Applies: debug settings, verbose logging, development tools
```

**Production Template:**
```bash
mulle-domain configure prod --template production
# Applies: optimized settings, security hardening, monitoring
```

**Staging Template:**
```bash
mulle-domain configure staging --template staging
# Applies: production-like settings with debug capabilities
```

### Custom Templates

```bash
# Create custom template
mulle-domain template create my-template --base development

# Apply custom template
mulle-domain configure mydomain --template my-template
```

## Common Workflows

### New Domain Setup

```bash
# Create and configure new domain
mulle-domain domain create myproject
mulle-domain configure myproject \
    --description "My Project Domain" \
    --template development \
    --enable-ssl

# Verify configuration
mulle-domain info myproject
```

### Environment-Specific Configuration

```bash
# Development environment
mulle-domain configure development \
    --template development \
    --verbose \
    --debug-enabled

# Staging environment
mulle-domain configure staging \
    --template staging \
    --enable-ssl \
    --monitoring-enabled

# Production environment
mulle-domain configure production \
    --template production \
    --ssl-required \
    --backup-enabled
```

### Migration Configuration

```bash
# Configure domain for migration
mulle-domain configure legacy \
    --template migration \
    --compatibility-mode \
    --data-migration-path /migration/data

# Configure new domain
mulle-domain configure modern \
    --template production \
    --ssl-required \
    --monitoring-enabled
```

## Advanced Configuration

### Multi-Environment Setup

```bash
# Configure multiple environments
for env in development staging production; do
    mulle-domain configure $env \
        --template $env \
        --environment $env \
        --enable-ssl
done
```

### Automated Configuration

```bash
#!/bin/bash
# Automated domain configuration script
DOMAIN_NAME=$1
TEMPLATE=${2:-development}

mulle-domain configure $DOMAIN_NAME \
    --template $TEMPLATE \
    --description "Auto-configured domain" \
    --enable-ssl \
    --verbose
```

### Configuration Validation

```bash
# Validate configuration
mulle-domain configure mydomain --validate

# Check configuration syntax
mulle-domain configure mydomain --check-syntax

# Preview configuration changes
mulle-domain configure mydomain --dry-run --verbose
```

## Troubleshooting

### Configuration Fails

```bash
# Check domain exists
mulle-domain domain list

# Verify permissions
ls -la .mulle-domain/

# Try with verbose output
mulle-domain configure mydomain --verbose
```

### Template Not Found

```bash
# List available templates
mulle-domain template list

# Check template path
mulle-domain template info <template-name>

# Create missing template
mulle-domain template create <template-name>
```

### SSL Configuration Issues

```bash
# Check SSL certificate files
ls -la /path/to/ssl/certs/

# Verify certificate validity
openssl x509 -in /path/to/cert.pem -text -noout

# Test SSL configuration
mulle-domain configure mydomain --test-ssl
```

### Path Configuration Problems

```bash
# Check path permissions
ls -la /custom/domain/path/

# Verify path exists
test -d /custom/domain/path/ || mkdir -p /custom/domain/path/

# Check disk space
df -h /custom/domain/path/
```

## Integration

### With Build Systems

```bash
# Configure domain for CMake
mulle-domain configure mydomain \
    --cmake-generator "Unix Makefiles" \
    --build-type Release

# Configure domain for Make
mulle-domain configure mydomain \
    --makefile /path/to/Makefile \
    --build-target all
```

### With CI/CD

```yaml
# .github/workflows/deploy.yml
- name: Configure Domain
  run: |
    mulle-domain configure production \
      --template production \
      --ssl-required \
      --monitoring-enabled
```

### With Configuration Management

```bash
# Ansible integration
ansible-playbook configure-domain.yml \
  -e "domain_name=mydomain template=production"

# Puppet integration
puppet apply manifests/domain.pp \
  --environment production
```

## Related Commands

- [`domain`](domain.md) - Manage domains
- [`settings`](settings.md) - Manage domain settings
- [`environment`](environment.md) - Manage environment variables
- [`template`](template.md) - Manage domain templates
- [`info`](info.md) - Show domain information