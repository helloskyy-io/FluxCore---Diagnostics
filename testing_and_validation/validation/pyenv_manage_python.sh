#!/bin/bash

# This script validates that pyenv is managing the Python version correctly
# runs after the application has been run at least once

echo "Switching to fluxuser..."
sudo su - fluxuser << 'EOF'
cd ~

echo "Checking the system's default Python version before activating pyenv:"
python3 --version

# Setup pyenv environment
echo "Setting up pyenv environment..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

echo "Activating the fluxcore-diagnostics virtual environment..."
pyenv activate fluxcore-diagnostics-env

# Check if the environment was activated correctly
if [ $? -eq 0 ]; then
    echo "Virtual environment activated successfully."
    echo "Checking Python version inside the virtual environment..."
    python --version
else
    echo "Failed to activate the virtual environment."
    exit 1
fi
EOF
