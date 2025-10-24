# Contributing to LinuxTools

Thank you for your interest in contributing to LinuxTools! This document provides guidelines and instructions for contributing.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, version, etc.)
   - Relevant logs or error messages

### Suggesting Enhancements

1. Check if the enhancement has been suggested
2. Create a new issue describing:
   - The problem your enhancement solves
   - How you propose to implement it
   - Any alternatives you've considered

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following our coding standards
4. Test your changes thoroughly
5. Commit with clear, descriptive messages
6. Push to your fork
7. Submit a pull request

## 📝 Coding Standards

### Bash Script Standards

All scripts must follow these guidelines:

#### 1. Shebang and Error Handling
```bash
#!/bin/bash
set -euo pipefail
```

#### 2. Documentation
- Add header comments explaining the script's purpose
- Document all functions
- Include usage examples

```bash
#!/bin/bash
#
# Script Name: example-script.sh
# Description: This script does something useful
# Usage: ./example-script.sh [options]
# Author: Your Name
# Date: YYYY-MM-DD
#

# Function: do_something
# Description: Performs a specific task
# Parameters:
#   $1 - First parameter description
# Returns: 0 on success, 1 on failure
do_something() {
    local param1="$1"
    # Implementation
}
```

#### 3. Color-Coded Output
Use consistent color coding:

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
```

#### 4. Logging
All scripts should log to `/var/log/linuxtools/`:

```bash
LOG_DIR="/var/log/linuxtools"
LOG_FILE="$LOG_DIR/$(basename $0 .sh)-$(date +%Y%m%d-%H%M%S).log"

# Log and display
print_info "Message" | tee -a "$LOG_FILE"
```

#### 5. Configuration Files
Store configurations in `/etc/linuxtools/`:

```bash
CONFIG_DIR="/etc/linuxtools"
CONFIG_FILE="$CONFIG_DIR/script-name.conf"
```

#### 6. Cross-Distribution Compatibility

Detect and support multiple distributions:

```bash
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    else
        DISTRO="unknown"
    fi
}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="apt-get install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
    fi
}
```

#### 7. Input Validation

Always validate user input:

```bash
validate_input() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        print_error "Input cannot be empty"
        return 1
    fi
    
    # Additional validation...
    return 0
}
```

#### 8. Error Handling

Implement proper error handling:

```bash
# Check command success
if ! command -v tool &> /dev/null; then
    print_error "Tool not found"
    exit 1
fi

# Use trap for cleanup
cleanup() {
    print_info "Cleaning up..."
    # Cleanup code
}
trap cleanup EXIT ERR
```

## 🧪 Testing

### Before Submitting

1. Test on multiple distributions (Ubuntu, CentOS, Debian)
2. Test with both root and non-root users (where applicable)
3. Test error conditions
4. Verify logging works correctly
5. Check for script portability

### Testing Checklist

- [ ] Script runs without errors
- [ ] Works on Ubuntu 20.04+
- [ ] Works on CentOS 7+
- [ ] Works on Debian 10+
- [ ] Proper error messages displayed
- [ ] Logs created correctly
- [ ] Configuration files created properly
- [ ] Cleanup happens on exit
- [ ] Help/usage information clear

## 📚 Documentation

### Required Documentation

1. **README Updates**: Update main README.md if adding new features
2. **Script Comments**: Add inline comments for complex logic
3. **Usage Examples**: Provide clear usage examples
4. **Configuration Documentation**: Document all configuration options

### Documentation Structure

```markdown
# Script Name

## Description
Brief description of what the script does

## Usage
```bash
./script-name.sh [options]
```

## Options
- `-h, --help`: Show help message
- `-v, --verbose`: Verbose output

## Examples
```bash
# Example 1
./script-name.sh --option value

# Example 2
./script-name.sh -v
```

## Requirements
- List of dependencies
- Required permissions
- Supported distributions
```

## 🔍 Code Review Process

1. All PRs require review before merging
2. Address all review comments
3. Ensure CI/CD checks pass
4. Keep PRs focused on single features
5. Squash commits if requested

## 📋 Commit Message Guidelines

Use clear, descriptive commit messages:

```
Add MySQL backup automation script

- Implements automated MySQL backup with compression
- Supports local and remote storage
- Includes backup rotation and cleanup
- Tested on Ubuntu 20.04 and CentOS 7
```

Format:
- First line: Brief summary (50 chars max)
- Blank line
- Detailed description (wrap at 72 chars)
- List specific changes

## 🏷️ Versioning

We use semantic versioning (SemVer):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🎯 Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR-USERNAME/SRE-Devops-secret-pendrive.git
cd SRE-Devops-secret-pendrive/LinuxTools

# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and test
# ...

# Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/my-new-feature
```

## 🤔 Questions?

- Open an issue for questions
- Check existing documentation
- Review similar scripts for examples

## 🙏 Thank You!

Your contributions help make LinuxTools better for everyone!
