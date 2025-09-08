# Branch Setup Instructions

This PR has been updated to change the package from `bmad-method` to `@axovia-ai/bmad-extension`.

## Manual Steps Required

To complete the setup, the following manual steps are needed:

### 1. Create the Target Branch

The new branch `bmad-core-v4-44-0-ext` needs to be created from the `bmad-code-org-sync` branch:

```bash
git checkout bmad-code-org-sync
git checkout -b bmad-core-v4-44-0-ext
git push origin bmad-core-v4-44-0-ext
```

### 2. Update PR Target

Once the branch is created, update this PR to target `bmad-core-v4-44-0-ext` instead of `bmad-code-org-sync`.

### 3. Package Installation

After the changes are merged to the new branch, the package can be installed as:

```bash
npm install @axovia-ai/bmad-extension
```

## Changes Made

- ✅ Updated package name from `bmad-method` to `@axovia-ai/bmad-extension`
- ✅ Updated repository URLs to point to `Axovia-AI/BMAD-METHOD`
- ✅ Added `bmad-extension` binary command
- ✅ Updated README.md installation instructions
- ✅ Updated installer package.json to match new package name
- ✅ Validated all changes with build and test
