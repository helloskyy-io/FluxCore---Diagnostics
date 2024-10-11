#!/bin/bash

# This script will test if pyenv can be temporarily added to the PATH
# and detect the pyenv installation.
# can only be run after the script has been previously run

# Set up the temporary PATH to include pyenv
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
