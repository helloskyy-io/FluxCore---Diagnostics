#!/bin/bash

# This script validates that pyenv is managing pip correctly
# runs after the application has been run at least once

# Initial check of pip packages in the base environment
echo "Checking pip packages in the base environment..."
pip list

# Now activate the virtual environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
pyenv activate fluxcore-diagnostics-env

echo "Virtual environment activated."

# Check pip packages in the activated virtual environment
echo "Checking pip packages in the virtual environment..."
pip list

# Deactivate the environment after the test
pyenv deactivate
echo "Virtual environment deactivated."

# Check pip packages after deactivation (should be back to base environment)
echo "Checking pip packages after deactivation..."
pip list

# Deactivate the environment after the test
pyenv deactivate
echo "Virtual environment deactivated."
