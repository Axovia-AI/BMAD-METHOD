#!/bin/bash

# BMAD Fork Management Script
# This script helps manage the Axovia-AI fork of BMAD-METHOD

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Current pinned version
PINNED_VERSION="v4.44.0"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in the right repository
check_repo() {
    if [[ ! -d ".git" ]]; then
        print_error "Not in a git repository. Please run this script from the BMAD-METHOD repository root."
        exit 1
    fi
    
    local origin_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$origin_url" != *"Axovia-AI/BMAD-METHOD"* ]]; then
        print_warning "This doesn't appear to be the Axovia-AI fork of BMAD-METHOD."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to setup upstream remote
setup_upstream() {
    print_status "Setting up upstream remote..."
    
    if git remote get-url upstream &>/dev/null; then
        print_status "Upstream remote already exists."
        local upstream_url=$(git remote get-url upstream)
        if [[ "$upstream_url" != *"bmad-code-org/BMAD-METHOD"* ]]; then
            print_warning "Upstream URL doesn't match expected URL."
            print_status "Current: $upstream_url"
            print_status "Expected: https://github.com/bmad-code-org/BMAD-METHOD.git"
        fi
    else
        git remote add upstream https://github.com/bmad-code-org/BMAD-METHOD.git
        print_success "Upstream remote added."
    fi
}

# Function to fetch upstream
fetch_upstream() {
    print_status "Fetching from upstream..."
    git fetch upstream --tags
    print_success "Upstream fetched successfully."
}

# Function to check current version
check_version() {
    local current_version=$(grep '"version"' package.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    print_status "Current version: $current_version"
    print_status "Pinned version: $PINNED_VERSION"
    
    if [[ "$current_version" == "${PINNED_VERSION#v}" ]]; then
        print_success "Version is correctly pinned to $PINNED_VERSION"
    else
        print_warning "Version mismatch detected!"
    fi
}

# Function to list available upstream versions
list_versions() {
    print_status "Available upstream versions (last 10):"
    git tag --list | grep "^v[0-9]" | sort -V | tail -10
}

# Function to show what changed between versions
show_changes() {
    local from_version="$1"
    local to_version="$2"
    
    if [[ -z "$from_version" || -z "$to_version" ]]; then
        print_error "Usage: show_changes <from_version> <to_version>"
        return 1
    fi
    
    print_status "Changes from $from_version to $to_version:"
    git log --oneline "$from_version".."$to_version" 2>/dev/null || {
        print_error "Could not find one or both versions. Run 'fetch_upstream' first."
        return 1
    }
}

# Function to validate current state
validate() {
    print_status "Running validation..."
    npm run validate
    print_success "Validation completed successfully."
}

# Function to create company extensions branch
create_extensions_branch() {
    local branch_name="axovia-extensions"
    
    print_status "Creating company extensions branch..."
    
    if git rev-parse --verify "$branch_name" &>/dev/null; then
        print_warning "Branch '$branch_name' already exists."
        git checkout "$branch_name"
    else
        git checkout -b "$branch_name" "$PINNED_VERSION"
        print_success "Created and switched to '$branch_name' branch based on $PINNED_VERSION"
    fi
}

# Function to update to a new version (careful operation)
update_version() {
    local new_version="$1"
    
    if [[ -z "$new_version" ]]; then
        print_error "Usage: update_version <version_tag>"
        print_status "Example: update_version v4.45.0"
        return 1
    fi
    
    # Check if version exists
    if ! git rev-parse --verify "$new_version" &>/dev/null; then
        print_error "Version $new_version not found. Run 'fetch_upstream' first."
        return 1
    fi
    
    print_warning "This will update the fork to $new_version"
    print_warning "This is a potentially destructive operation!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        return 0
    fi
    
    # Create backup branch
    local backup_branch="backup-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$backup_branch"
    print_status "Created backup branch: $backup_branch"
    
    # Update to new version
    git checkout main 2>/dev/null || git checkout -b main
    git reset --hard "$new_version"
    
    # Update package.json version
    local version_number="${new_version#v}"
    sed -i.bak "s/\"version\": *\"[^\"]*\"/\"version\": \"$version_number\"/" package.json
    sed -i.bak "s/\"version\": *\"[^\"]*\"/\"version\": \"$version_number\"/" tools/installer/package.json
    rm -f package.json.bak tools/installer/package.json.bak
    
    # Update dist files
    git checkout "$new_version" -- dist/
    
    # Commit changes
    git add package.json tools/installer/package.json dist/
    git commit -m "Update to $new_version"
    
    # Update the pinned version in this script
    sed -i.bak "s/PINNED_VERSION=\"[^\"]*\"/PINNED_VERSION=\"$new_version\"/" "$0"
    rm -f "${0}.bak"
    
    print_success "Updated to $new_version"
    print_status "Don't forget to test thoroughly and update the extensions branch!"
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        "setup")
            check_repo
            setup_upstream
            fetch_upstream
            check_version
            ;;
        "fetch")
            check_repo
            fetch_upstream
            ;;
        "status")
            check_repo
            check_version
            ;;
        "versions")
            check_repo
            list_versions
            ;;
        "changes")
            check_repo
            show_changes "$2" "$3"
            ;;
        "validate")
            check_repo
            validate
            ;;
        "extensions")
            check_repo
            create_extensions_branch
            ;;
        "update")
            check_repo
            update_version "$2"
            ;;
        "help"|"--help"|"-h"|"")
            echo "BMAD Fork Management Script"
            echo
            echo "Usage: $0 <command> [arguments]"
            echo
            echo "Commands:"
            echo "  setup          - Initial setup of upstream remote and fetch"
            echo "  fetch          - Fetch latest from upstream"
            echo "  status         - Check current version status"
            echo "  versions       - List available upstream versions"
            echo "  changes <from> <to> - Show changes between versions"
            echo "  validate       - Run BMAD validation"
            echo "  extensions     - Create/switch to company extensions branch"
            echo "  update <version> - Update to new upstream version (careful!)"
            echo "  help           - Show this help message"
            echo
            echo "Examples:"
            echo "  $0 setup                    # Initial setup"
            echo "  $0 changes v4.43.0 v4.44.0 # Show changes between versions"
            echo "  $0 update v4.45.0          # Update to new version"
            ;;
        *)
            print_error "Unknown command: $command"
            print_status "Run '$0 help' for usage information."
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"