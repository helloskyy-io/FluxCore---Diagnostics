#!/bin/bash

# This script will test if pyenv can be temporarily added to the PATH
# and detect the pyenv installation.

# Check if pyenv is available before setting up the temporary PATH
if command -v pyenv &> /dev/null; then
    echo "Error: pyenv is already available in this session. Test cannot proceed."
    exit 1
else
    echo "pyenv is not available in this session, proceeding with test."
fi

# Set up the temporary PATH to include pyenv
echo "temporarily adding pyenv to path"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Check if pyenv is available in this session
if command -v pyenv &> /dev/null; then
    echo "pyenv is available in this session."
else
    echo "pyenv is NOT available. Test failed."
    exit 1
fi

# Verify pyenv version detection
if pyenv versions | grep -q "3.12.0"; then
    echo "Python 3.12.0 is installed and detected by pyenv."
else
    echo "Python 3.12.0 is not detected by pyenv. Test failed."
    exit 1
fi

echo "Test passed successfully!"
