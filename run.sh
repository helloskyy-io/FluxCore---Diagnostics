#!/bin/bash

# Function to manage sudo
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

# Function to install pyenv if not already installed
install_pyenv() {
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Installing pyenv..."
        curl https://pyenv.run | bash
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        source ~/.bashrc
    else
        echo "pyenv is already installed."
    fi
}

# Function to install Python 3.12 using pyenv
install_python_version() {
    if ! pyenv versions | grep -q "3.12.0"; then
        echo "Installing Python 3.12..."
        pyenv install 3.12.0
    else
        echo "Python 3.12 is already installed."
    fi
}

# Function to create virtual environment
create_virtualenv() {
    if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
        echo "Creating virtual environment..."
        pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
    else
        echo "Virtual environment already exists."
    fi
}

# Function to install Python packages
install_python_packages() {
    echo "Installing required Python packages..."
    pip install --upgrade pip
    pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt
}

# Main function to run everything under fluxuser
run_as_fluxuser() {
    sudo -u fluxuser bash << 'EOF'

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi

    # Install pyenv if not already installed
    $(install_pyenv)

    # Install Python 3.12 if not installed
    $(install_python_version)

    # Create a virtual environment if it doesn't exist
    $(create_virtualenv)

    # Activate the virtual environment
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    pyenv activate fluxcore-diagnostics-env

    # Install Python packages
    $(install_python_packages)

    # Run the diagnostics Python script
    python /home/fluxuser/FluxCore-Diagnostics/py/diagnostics.py

EOF
}

# Main Execution
sudo_check
run_as_fluxuser

