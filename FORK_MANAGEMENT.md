# Fork Management Strategy

This document outlines the branching strategy and workflow for managing the Axovia-AI fork of the BMAD-METHOD repository.

## Overview

This fork is pinned to **v4.44.0** of the upstream bmad-code-org/BMAD-METHOD repository to ensure stability while allowing for company-specific extensions.

## Repository Structure

### Remotes

- `origin`: https://github.com/Axovia-AI/BMAD-METHOD (our fork)
- `upstream`: https://github.com/bmad-code-org/BMAD-METHOD (original repository)

### Branch Strategy

#### Main Branch (`main`)

- **Purpose**: Pristine branch that tracks upstream releases
- **Usage**: Kept synchronized with upstream bmad-code-org/BMAD-METHOD
- **Policy**: No direct commits allowed - only merges from upstream or hotfixes

#### Company Extensions Branch (`axovia-extensions`)

- **Purpose**: Company-specific modifications and extensions
- **Base**: Branched from v4.44.0 tag
- **Usage**: All Axovia-AI specific features, customizations, and extensions
- **Policy**: Regular merges from main branch to stay updated

#### Feature Branches

- **Naming**: `feature/description` or `axovia/feature-name`
- **Base**: Branch from `axovia-extensions`
- **Usage**: Individual features and improvements
- **Policy**: Merge into `axovia-extensions` via pull requests

## Pinning Strategy

### Current Pin: v4.44.0

The fork is currently pinned to v4.44.0 of the upstream repository. This means:

1. **Stability**: Known working version for Axovia-AI's use cases
2. **Controlled Updates**: Upgrades are intentional and tested
3. **Extension Compatibility**: Company extensions remain compatible

### Version Management

- Package version reflects the pinned upstream version (4.44.0)
- Internal extensions can use patch versions (e.g., 4.44.0-axovia.1)

## Workflow

### Setting Up the Fork

```bash
# Clone the fork
git clone https://github.com/Axovia-AI/BMAD-METHOD.git
cd BMAD-METHOD

# Add upstream remote
git remote add upstream https://github.com/bmad-code-org/BMAD-METHOD.git

# Fetch upstream tags and branches
git fetch upstream --tags
```

### Working with Company Extensions

```bash
# Create or switch to extensions branch
git checkout -b axovia-extensions v4.44.0

# Create feature branch for new work
git checkout -b feature/my-new-feature axovia-extensions

# After completing feature, merge back
git checkout axovia-extensions
git merge feature/my-new-feature
```

### Updating to a New Upstream Version (When Ready)

```bash
# Fetch latest from upstream
git fetch upstream --tags

# Check available versions
git tag --list | grep "v4\." | sort -V

# Update main branch to new version (e.g., v4.45.0)
git checkout main
git reset --hard v4.45.0

# Update extensions branch by rebasing or merging
git checkout axovia-extensions
git rebase main  # or: git merge main

# Update package.json version numbers
# Test thoroughly before proceeding
```

## Best Practices

### 1. Regular Synchronization

- Periodically check for upstream updates
- Evaluate new versions for stability and compatibility
- Plan upgrade cycles that align with development schedules

### 2. Change Isolation

- Keep company-specific changes in dedicated branches
- Use clear commit messages indicating custom modifications
- Document any deviations from upstream behavior

### 3. Testing Strategy

- Test all company extensions after upstream updates
- Maintain automated tests for custom functionality
- Validate BMAD-METHOD core functionality remains intact

### 4. Documentation

- Document all custom modifications
- Keep track of reasons for staying on specific versions
- Maintain upgrade notes and compatibility matrices

## Troubleshooting

### Merge Conflicts

When updating from upstream, conflicts may occur in:

- `package.json` (version numbers)
- `dist/` files (built distributions)
- Configuration files

Resolution strategy:

1. Favor upstream changes for core functionality
2. Preserve company-specific configurations
3. Test thoroughly after conflict resolution

### Extension Compatibility

If company extensions break after upstream updates:

1. Identify the breaking changes in upstream
2. Update extensions to match new APIs/structure
3. Consider contributing useful changes back to upstream

## Contributing Back to Upstream

When developing features that could benefit the broader community:

1. Develop in a separate branch based on upstream main
2. Submit pull request to bmad-code-org/BMAD-METHOD
3. Once merged upstream, update our fork accordingly

## Security Considerations

- Regularly update dependencies in company extensions
- Monitor upstream security advisories
- Never commit sensitive company information to the fork
- Use environment variables or separate config files for secrets

## Support and Maintenance

### Team Responsibilities

- **DevOps Team**: Repository setup, branch management, CI/CD
- **Development Team**: Feature development, testing, code reviews
- **Architecture Team**: Extension design, upstream evaluation

### Review Schedule

- **Monthly**: Check for upstream updates and security patches
- **Quarterly**: Evaluate pinned version and consider upgrades
- **Semi-annually**: Review and update this strategy document

---

For questions or updates to this strategy, please contact the DevOps team or create an issue in this repository.
