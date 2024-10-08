#!/bin/bash

# Function to manage Sudo
sudo_check() {
    echo "Checking if sudo requires a password..."
    if sudo -n true 2>/dev/null; then
        echo "Sudo does not require a password."
    else
        echo "Sudo requires a password. Please enter your password:"
        sudo -v
        if [ $? -ne 0 ]; then
            echo "Incorrect password or sudo authentication failed."
            exit 1
        fi
    fi
    echo ""
}

# Main function to run everything under fluxuser
run_as_fluxuser() {
    sudo -i -u fluxuser bash << 'EOF'
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        echo "curl not found. Please install it before running the script."
        exit 1
    fi

    # Ensure pyenv is properly configured
    export PYENV_ROOT="\$HOME/.pyenv"
    export PATH="\$PYENV_ROOT/bin:\$PATH"

    # Check if pyenv is installed
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Installing pyenv..."
        curl https://pyenv.run | bash

        # Add pyenv to bashrc for future sessions
        echo 'export PYENV_ROOT="\$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="\$PYENV_ROOT/bin:\$PATH"' >> ~/.bashrc
        echo 'eval "\$(pyenv init --path)"' >> ~/.bashrc
        echo 'eval "\$(pyenv init -)"' >> ~/.bashrc

        # Source the bashrc to reload environment
        source ~/.bashrc
    fi

    # Initialize pyenv in the current shell
    if command -v pyenv >/dev/null 2>&1; then
        eval "\$(pyenv init --path)"
        eval "\$(pyenv init -)"
    else
        echo "pyenv is still not available after installation"
        exit 1
    fi

    # Install Python 3.12 if not installed
    if ! pyenv versions | grep -q "3.12.0"; then
        echo "Installing Python 3.12..."
        pyenv install 3.12.0
    fi

    # Create a virtual environment if it doesn't exist
    if [ ! -d "\$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
        echo "Creating virtual environment..."
        pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
    fi

    # Activate the virtual environment
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    pyenv activate fluxcore-diagnostics-env

    # Install Python packages
    echo "Installing required Python packages..."
    pip install --upgrade pip
    pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

    # Run the diagnostics Python script
    python /home/fluxuser/FluxCore-Diagnostics/py/diagnostics.py

EOF
}

# Main Execution
sudo_check
run_as_fluxuser
