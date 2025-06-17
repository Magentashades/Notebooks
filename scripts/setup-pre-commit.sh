#!/bin/bash

# Setup script for pre-commit hook
# This script helps new users configure the pre-commit hook properly

echo "Setting up pre-commit hook for YESS Notebooks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository."
    exit 1
fi

print_status "Checking prerequisites..."

# Check if Docker is installed
if ! command_exists docker; then
    print_error "Docker is not installed. Please install Docker first:"
    echo "  https://docs.docker.com/get-docker/"
    exit 1
else
    print_success "Docker is installed"
fi

# Check if docker-compose is installed
if ! command_exists docker-compose; then
    print_error "docker-compose is not installed. Please install docker-compose first:"
    echo "  https://docs.docker.com/compose/install/"
    exit 1
else
    print_success "docker-compose is installed"
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
else
    print_success "Docker is running"
fi

print_status "Setting up pre-commit hook..."

# Check if pre-commit hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    print_warning "Pre-commit hook already exists. Backing up existing hook..."
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup.$(date +%Y%m%d_%H%M%S)
fi

# Make sure the pre-commit hook is executable
if [ -f ".git/hooks/pre-commit" ]; then
    chmod +x .git/hooks/pre-commit
    print_success "Pre-commit hook is executable"
else
    print_error "Pre-commit hook not found at .git/hooks/pre-commit"
    print_error "Please ensure the pre-commit hook file exists in the repository."
    exit 1
fi

# Test the pre-commit hook
print_status "Testing pre-commit hook..."

# Create a temporary test notebook if none exist
test_notebook="test_precommit.ipynb"
if [ ! -f "$test_notebook" ]; then
    print_status "Creating test notebook for verification..."
    cat > "$test_notebook" << 'EOF'
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Hello, World!\n"
     ]
    }
   ],
   "source": [
    "print('Hello, World!')"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
fi

# Stage the test notebook
git add "$test_notebook" 2>/dev/null

# Test the pre-commit hook (but don't actually commit)
print_status "Running pre-commit hook test..."
if .git/hooks/pre-commit; then
    print_success "Pre-commit hook test passed!"
    
    # Check if output was stripped
    if grep -q '"outputs"' "$test_notebook"; then
        print_warning "Test notebook still contains outputs - this might be expected if the container isn't running"
    else
        print_success "Output was successfully stripped from test notebook"
    fi
else
    print_error "Pre-commit hook test failed!"
    print_error "Please check the error messages above and ensure Docker is running."
    exit 1
fi

# Clean up test notebook
git reset HEAD "$test_notebook" 2>/dev/null
rm -f "$test_notebook"

print_status "Setting up manual notebook cleaning script..."

# Make sure the strip-notebooks script is executable
if [ -f "scripts/strip-notebooks.sh" ]; then
    chmod +x scripts/strip-notebooks.sh
    print_success "Manual notebook cleaning script is executable"
else
    print_warning "Manual notebook cleaning script not found at scripts/strip-notebooks.sh"
fi

print_success "Pre-commit hook setup completed!"

echo ""
echo "What happens next:"
echo "1. The pre-commit hook will automatically run when you commit Jupyter notebooks"
echo "2. It will strip all output cells from notebooks before committing"
echo "3. You can manually clean all notebooks with: ./scripts/strip-notebooks.sh"
echo ""
echo "To test the setup:"
echo "1. Make changes to a Jupyter notebook"
echo "2. Run: git add <notebook-file>"
echo "3. Run: git commit -m 'Test commit'"
echo "4. The pre-commit hook should automatically strip outputs"
echo ""
print_success "Setup complete! You're ready to use the pre-commit hook." 