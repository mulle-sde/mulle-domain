# mulle-domain Command Reference

## Overview

**mulle-domain** is a cross-platform tool for parsing and composing source code repository URLs. It can guess project names from URLs, access tag information from repositories hosted on known domains (GitHub, GitLab, SourceForge, etc.), and work with various repository types including git, tar, and zip archives.

## Command Categories

### URL Analysis
- **[`nameguess`](nameguess.md)** - Guess final filename from URL
- **[`typeguess`](typeguess.md)** - Guess repository type from URL
- **[`parse-url`](parse-url.md)** - Parse components from a repository URL

### URL Construction
- **[`compose-url`](compose-url.md)** - Create repository URLs from components

### Repository Information
- **[`tags`](tags.md)** - List all tags of a repository
- **[`tags-with-commits`](tags-with-commits.md)** - List tags with commit identifiers
- **[`resolve`](resolve.md)** - Get tag that matches a semver qualifier best

### System Information
- **[`list`](list.md)** - List known repository domains for which plugins exist

## Quick Start Examples

### Basic URL Analysis
```bash
# Guess project name from GitHub URL
mulle-domain nameguess https://github.com/mulle-objc/MulleObjC/archive/refs/tags/0.19.0.zip
# Output: MulleObjC

# Determine repository type
mulle-domain typeguess https://github.com/mulle-objc/MulleObjC.git
# Output: git

# Parse URL components
mulle-domain parse-url https://github.com/user/repo/archive/v1.0.0.tar.gz
```

### Working with Repository Tags
```bash
# List all tags from a GitHub repository
mulle-domain tags https://github.com/mulle-objc/MulleObjC

# Get latest version matching semver pattern
mulle-domain resolve https://github.com/mulle-objc/MulleObjC "^1.0.0"

# List tags with commit information
mulle-domain tags-with-commits https://github.com/mulle-objc/MulleObjC
```

### URL Construction
```bash
# Create GitHub release URL
mulle-domain compose-url github user repo v1.0.0

# Create archive download URL
mulle-domain compose-url github user repo archive v1.0.0
```

### Repository Type Detection
```bash
# Detect different repository types
mulle-domain typeguess https://github.com/user/repo.git          # git
mulle-domain typeguess https://github.com/user/repo/archive/v1.0.0.tar.gz  # tar
mulle-domain typeguess https://github.com/user/repo/archive/v1.0.0.zip     # zip
mulle-domain typeguess /local/path/to/project                    # local
```

## Command Reference Table

| Command | Category | Description |
|---------|----------|-------------|
| `nameguess` | Analysis | Guess filename from URL |
| `typeguess` | Analysis | Guess repository type from URL |
| `parse-url` | Analysis | Parse URL into components |
| `compose-url` | Construction | Create URL from components |
| `tags` | Repository | List repository tags |
| `tags-with-commits` | Repository | List tags with commit info |
| `resolve` | Repository | Find tag matching semver |
| `list` | System | List supported domains |

## Getting Help

### Command Help
```bash
# Get help for specific command
mulle-domain <command> --help

# Get detailed help
mulle-domain <command> --help --verbose

# List all commands
mulle-domain --help
```

### Documentation
- Each command has a dedicated documentation file in this reference
- Use `--help` for quick command usage
- Check `mulle-domain list` for supported repository domains

## Common Workflows

### Repository Analysis
1. **Guess** project name: `mulle-domain nameguess <url>`
2. **Determine** repository type: `mulle-domain typeguess <url>`
3. **Parse** URL components: `mulle-domain parse-url <url>`

### Version Management
1. **List** available tags: `mulle-domain tags <url>`
2. **Find** specific version: `mulle-domain resolve <url> <semver>`
3. **Get** tags with commits: `mulle-domain tags-with-commits <url>`

### URL Construction
1. **Create** repository URL: `mulle-domain compose-url <domain> <user> <repo>`
2. **Build** archive URL: `mulle-domain compose-url <domain> <user> <repo> archive <tag>`

## Advanced Usage

### Working with Different Repository Types
```bash
# Git repositories
mulle-domain typeguess https://github.com/user/repo.git          # git
mulle-domain typeguess git@github.com:user/repo.git              # git

# Archive files
mulle-domain typeguess https://github.com/user/repo/archive/v1.0.0.tar.gz  # tar
mulle-domain typeguess https://github.com/user/repo/archive/v1.0.0.zip     # zip

# Local paths
mulle-domain typeguess /path/to/local/project                    # local
mulle-domain typeguess ./relative/path                           # local
```

### Advanced Name Guessing
```bash
# Standard GitHub URLs
mulle-domain nameguess https://github.com/user/repo.git          # repo
mulle-domain nameguess https://github.com/user/repo              # repo

# Archive downloads
mulle-domain nameguess https://github.com/user/repo/archive/v1.0.0.tar.gz  # repo
mulle-domain nameguess https://github.com/user/repo/archive/v1.0.0.zip     # repo

# Versioned archives
mulle-domain nameguess https://example.com/project-1.2.3.tar.gz  # project
mulle-domain nameguess https://example.com/lib-2.0.1.zip         # lib
```

### Semver Resolution
```bash
# Find latest version
mulle-domain resolve https://github.com/user/repo "*"

# Find compatible version
mulle-domain resolve https://github.com/user/repo "^1.0.0"

# Find specific major version
mulle-domain resolve https://github.com/user/repo "2.*"

# Find exact version
mulle-domain resolve https://github.com/user/repo "1.2.3"
```

### Repository Tag Analysis
```bash
# List all tags
mulle-domain tags https://github.com/user/repo

# Get tags with commit information
mulle-domain tags-with-commits https://github.com/user/repo

# Filter by pattern
mulle-domain tags https://github.com/user/repo | grep "v1\."
```

## Troubleshooting

### URL Parsing Issues
```bash
# Check if URL is supported
mulle-domain list

# Verify URL format
mulle-domain parse-url <problematic-url>

# Test with different URL formats
mulle-domain typeguess <url>
```

### Repository Access Problems
```bash
# Check repository accessibility
curl -I <repository-url>

# Verify repository exists
mulle-domain tags <repository-url>

# Check for authentication requirements
mulle-domain tags https://github.com/user/private-repo
```

### Command Errors
```bash
# Get detailed error information
mulle-domain <command> --verbose

# Check command syntax
mulle-domain <command> --help

# Verify supported domains
mulle-domain list
```

## Integration with Other Tools

### Build Systems
```bash
# Use with mulle-fetch for dependency management
mulle-fetch add $(mulle-domain compose-url github user repo v1.0.0)

# Generate download URLs for CI/CD
DOWNLOAD_URL=$(mulle-domain compose-url github user repo archive $(mulle-domain resolve github user repo "*"))
```

### Development Tools
```bash
# Script repository cloning
REPO_URL=$(mulle-domain compose-url github user repo)
git clone $REPO_URL

# Version checking in build scripts
LATEST_TAG=$(mulle-domain resolve https://github.com/user/repo "*")
echo "Latest version: $LATEST_TAG"
```

### Package Management
```bash
# Generate package URLs
PACKAGE_URL=$(mulle-domain compose-url github user repo archive v1.0.0)
wget $PACKAGE_URL

# Check available versions
mulle-domain tags https://github.com/user/repo | sort -V
```

## Supported Repository Domains

mulle-domain supports various repository hosting services through plugins:

- **GitHub** (`github`) - GitHub.com repositories
- **GitLab** (`gitlab`) - GitLab.com and self-hosted instances
- **SourceForge** (`sourceforge`) - SourceForge.net projects
- **Generic** (`generic`) - Generic git repositories
- **CLib** (`clib`) - C library package manager
- **GitHub Content** (`githubusercontent`) - Raw GitHub content

## Related Documentation

- **[README.md](../../README.md)** - Project overview and installation
- **[mulle-fetch](../mulle-fetch/)** - Integration with fetch operations
- **[mulle-sde](../mulle-sde/)** - Build system integration
- **[Name Guessing](./nameguess.md)** - Detailed name guessing rules
- **[Type Detection](./typeguess.md)** - Repository type detection