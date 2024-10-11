#!/bin/bash

# this test requires first removing pyenv if instlaled
# sudo rm -rf ~/.pyenv
# Step 1: Set pyenv path for the session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Function to simulate the `install_pyenv` call from the script
test_pyenv_install() {
    # Simulate the install_pyenv function
    echo "Checking if pyenv is installed..."

    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Installing pyenv..."
        curl https://pyenv.run | bash
        if [ $? -ne 0 ]; then
            echo "Error: pyenv installation failed."
            exit 1
        fi
        echo "pyenv installation complete."
    else
        echo "pyenv is already installed."
    fi
}

# Step 2: First Run - pyenv should not be found and should trigger the installation
echo "=== First Run: Expecting pyenv to be missing and installed ==="
test_pyenv_install

# Step 3: Second Run - pyenv should be recognized and installation skipped
echo "=== Second Run: Expecting pyenv to be recognized and skipped ==="
test_pyenv_install

# Check if pyenv is now installed
command -v pyenv &> /dev/null && echo "Pyenv installation validation passed." || echo "Pyenv installation validation failed."

# End of test
