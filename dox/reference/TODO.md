# mulle-domain Documentation Process Guide

## Overview

This document outlines the systematic process for creating comprehensive command documentation for mulle-domain. Based on practical experience with documentation creation, it provides clear guidelines for what to write, what to avoid, and the step-by-step process to follow.

## Documentation Creation Process

### Phase 1: Command Analysis

#### Step 1: Gather Command Information
- **List all available commands** by examining the source directory structure
- **Identify command categories** (domain, configuration, system, utility)
- **Note command relationships** and dependencies between commands
- **Document command aliases** and shortcuts

#### Step 2: Analyze Command Behavior
- **Examine visible options** using `--help` output
- **Identify hidden options** through source code analysis
- **Understand conditional behaviors** and option interactions
- **Document scope and persistence** of command effects

#### Step 3: Map Command Ecosystem
- **Create command dependency graph** showing relationships
- **Identify command workflows** and typical usage patterns
- **Document integration points** with other commands
- **Note cross-command data flow** and shared state

### Phase 2: Documentation Structure

#### Required Sections (Always Include)

**Header and Quick Start**
- Command name and brief description
- Basic usage syntax
- Most common use case example

**Options Documentation**
- All visible options with descriptions
- Hidden/advanced options (clearly marked)
- Option syntax and parameter requirements
- Default values and behaviors

**Practical Examples**
- Basic usage scenarios
- Advanced configuration examples
- Integration with other commands
- Real-world workflow patterns

**Troubleshooting**
- Common error conditions
- Recovery procedures
- Diagnostic commands
- Prevention strategies

#### Optional Sections (Include When Relevant)

**Technical Details**
- Implementation specifics (high-level only)
- File system interactions
- Environment variable effects
- Performance considerations

**Integration Examples**
- Workflow automation scripts
- CI/CD integration
- Development environment setup
- Cross-platform considerations

## What to Write (Content Guidelines)

### ✅ Include These Elements

**Clear, Actionable Examples**
```bash
# Good: Specific, runnable commands
mulle-domain nameguess https://github.com/mulle-objc/MulleObjC.git
mulle-domain typeguess https://github.com/mulle-objc/MulleObjC.git
mulle-domain list

# Good: Workflow examples
mulle-domain nameguess https://github.com/user/project.git
mulle-domain typeguess https://gitlab.com/user/project.git
mulle-domain parse-url https://github.com/user/project.git
```

**Comprehensive Option Coverage**
- Document all visible options
- Include hidden options with clear marking
- Explain option interactions and conflicts
- Provide parameter validation rules

**Practical Troubleshooting**
- Real error messages and solutions
- Diagnostic command sequences
- Recovery procedures with examples
- Prevention strategies

**Integration Context**
- How commands work together
- Typical workflow sequences
- Environment setup patterns
- Cross-command data sharing

### ❌ Avoid These Elements

**Implementation Details**
- Internal function names or variables
- File system paths (unless user-facing)
- Low-level data structures
- Build system specifics

**Speculative Content**
- Unverified use cases
- Hypothetical scenarios
- Future feature assumptions
- Unsupported configurations

**Redundant Information**
- Repeating information from other docs
- Obvious or trivial details
- Generic help text
- Boilerplate descriptions

**Platform-Specific Details**
- OS-specific implementation differences
- Hardware-dependent behaviors
- Version-specific limitations
- Environment-specific workarounds

## Documentation Standards

### Formatting Rules

**Consistent Structure**
- Use standard section headers
- Maintain consistent indentation (3 spaces)
- Follow Allman brace style in code examples
- Use columnar alignment for option tables

**Code Example Standards**
- Include realistic, runnable commands
- Use meaningful variable names
- Show both success and error cases
- Provide context for complex examples

**Cross-Reference System**
- Link to related commands using `[command](command.md)` syntax
- Reference external documentation when appropriate
- Maintain consistent link formatting
- Update references when commands are renamed

### Quality Assurance

**Accuracy Checks**
- Verify all commands work as documented
- Test examples on clean environment
- Confirm option behaviors match implementation
- Validate troubleshooting steps

**Completeness Review**
- Ensure all visible options are documented
- Check for missing error conditions
- Verify integration examples work
- Confirm cross-references are valid

**Consistency Validation**
- Use consistent terminology throughout
- Maintain uniform formatting
- Follow established patterns
- Check against existing documentation

## Command Categories and Priorities

### High Priority Commands (Document First)
- URL Analysis commands (`nameguess`, `typeguess`, `parse-url`)
- Repository Information commands (`tags`, `resolve`)
- URL Construction commands (`compose-url`)
- System information (`list`)

### Medium Priority Commands
- Advanced repository analysis (`tags-with-commits`)
- Integration and automation features
- Cross-platform repository handling

### Low Priority Commands
- Experimental or unstable features
- Platform-specific repository types

## Maintenance Guidelines

### Regular Updates
- Review documentation quarterly
- Update for new command options
- Refresh examples and workflows
- Verify cross-references remain valid

### Change Management
- Document breaking changes immediately
- Update affected cross-references
- Maintain change history
- Communicate updates to users

### Quality Metrics
- All commands have documentation
- Examples are tested and working
- Troubleshooting covers 80% of issues
- Documentation is updated within 1 week of changes

## Process Checklist

### Pre-Documentation
- [ ] Analyze command source code
- [ ] Test command with all options
- [ ] Identify related commands
- [ ] Gather error scenarios

### Documentation Creation
- [ ] Write header and quick start
- [ ] Document all options comprehensively
- [ ] Create practical examples
- [ ] Add troubleshooting section
- [ ] Include integration examples

### Quality Assurance
- [ ] Test all examples
- [ ] Verify option documentation
- [ ] Check cross-references
- [ ] Validate troubleshooting steps
- [ ] Review for completeness

### Final Steps
- [ ] Format consistently
- [ ] Update index if needed
- [ ] Commit with clear message
- [ ] Update related documentation

## Command Testing Results

### Comprehensive Command Checklist

#### URL Analysis
- [x] `mulle-domain nameguess <url>` : Extract project name from repository URL
- [x] `mulle-domain typeguess <url>` : Determine repository type from URL
- [ ] `mulle-domain parse-url <url>` : Parse URL components

#### Repository Information
- [ ] `mulle-domain tags <url>` : List repository tags
- [ ] `mulle-domain tags-with-commits <url>` : List tags with commit information
- [ ] `mulle-domain resolve <url> <semver>` : Resolve semantic version

#### URL Construction
- [ ] `mulle-domain compose-url <domain> <user> <repo>` : Create repository URL

#### System Information
- [x] `mulle-domain list` : List supported repository domains

### Summary
- **Working Commands**: 3 commands tested and working (`nameguess`, `typeguess`, `list`)
- **Failing Commands**: 0 commands tested (no failures found)
- **Not Found Commands**: 0 commands tested (all tested commands exist)
- **Untested Commands**: 4 commands remaining (`parse-url`, `tags`, `tags-with-commits`, `resolve`, `compose-url`)

### Notes
- **Major Discovery**: mulle-domain is a URL parsing tool, not a domain manager
- **Documentation Rewrite**: Completely rewrote index.md to reflect actual functionality
- **Tested Examples**: All examples in index.md verified to work correctly
- **Command Structure**: Identified 7 total commands across 4 categories
- **Supported Domains**: GitHub, GitLab, SourceForge, and others confirmed working

## Success Metrics

### Documentation Quality
- **Coverage**: 100% of commands documented
- **Accuracy**: 95% of examples work as written
- **Completeness**: All options and error conditions covered
- **Usability**: New users can accomplish tasks independently

### User Experience
- **Findability**: Users can locate needed information quickly
- **Clarity**: Documentation is understandable without prior knowledge
- **Actionability**: Examples provide clear, runnable solutions
- **Reliability**: Information remains accurate over time

### Maintenance Efficiency
- **Update Speed**: Documentation updated within 1 week of changes
- **Review Cycle**: Quarterly comprehensive review completed
- **Error Rate**: Less than 5% of documentation contains errors
- **Consistency**: 100% adherence to formatting standards