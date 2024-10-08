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

# Function to install system dependencies for Python build
install_dependencies() {
    echo "Installing development libraries required for Python build..."
    sudo apt-get update
    sudo apt-get install -y \
        libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev libffi-dev \
        liblzma-dev libncurses5-dev libncursesw5-dev \
        build-essential
}

# Function to install pyenv as fluxuser if not already installed
install_pyenv() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found or not properly installed. Cleaning up and reinstalling pyenv..."

        # Remove any existing pyenv directory to avoid conflicts
        sudo rm -rf /home/fluxuser/.pyenv
        
        # Install pyenv
        curl https://pyenv.run | bash

        # Add pyenv to bashrc for future sessions (only needed on first install)
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

        # Source bashrc to apply pyenv immediately
        source ~/.bashrc
    else
        echo "pyenv already installed."
    fi

    # Ensure pyenv is initialized in the current session
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
EOF
}

# Function to install Python 3.12 if not installed
install_python() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    if ! pyenv versions | grep -q "3.12.0"; then
        echo "Installing Python 3.12..."
        pyenv install 3.12.0
    else
        echo "Python 3.12 already installed."
    fi
EOF
}

# Function to create a virtual environment if it doesn't exist
create_virtualenv() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
        echo "Creating virtual environment..."
        pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
    else
        echo "Virtual environment already exists."
    fi
EOF
}

# Function to install Python packages inside the virtualenv
install_python_packages() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    pyenv activate fluxcore-diagnostics-env

    # Upgrade pip
    pip install --upgrade pip

    # Install required Python packages from pinned_reqs.txt
    pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt
EOF
}

# Function to activate the virtualenv and run diagnostics
run_diagnostics() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    pyenv activate fluxcore-diagnostics-env

    echo "Running diagnostics..."
    python /home/fluxuser/FluxCore-Diagnostics/py/diagnostics.py
EOF
}

# Main Execution Flow
sudo_check

# Install system dependencies only if needed (on first install)
sudo -i -u fluxuser bash << 'EOF'
if ! pyenv versions | grep -q "3.12.0"; then
    exit 1  # Signal that dependencies are needed
else
    exit 0  # Dependencies already installed
fi
EOF
if [ $? -ne 0 ]; then
    install_dependencies
fi

# Install pyenv for fluxuser
install_pyenv

# Install Python 3.12 if not already installed
install_python

# Create virtual environment if not already created
create_virtualenv

# Install necessary Python packages inside the virtualenv
install_python_packages

# Run diagnostics
run_diagnostics



