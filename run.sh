#!/bin/bash

# Function to manage sudo permissions
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

# Function to install system dependencies
install_dependencies() {
    echo "Installing development libraries required for Python build..."
    sudo apt-get update
    sudo apt-get install -y \
        libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev libffi-dev \
        liblzma-dev libncurses5-dev libncursesw5-dev \
        build-essential
}

# Function to install pyenv as fluxuser
install_pyenv() {
    sudo -i -u fluxuser bash << 'EOF'
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found or not properly installed. Installing pyenv..."
        curl https://pyenv.run | bash
        
        # Add pyenv to bashrc for future sessions
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

# Function to create a virtualenv for diagnostics
create_virtualenv() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
        echo "Creating virtual environment..."
        pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
    fi
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
if ! pyenv versions | grep -q "3.12.0"; then
    install_dependencies
fi

# Install pyenv for fluxuser
install_pyenv

# Install Python 3.12 if not already installed
install_python

# Create virtual environment if not already created
create_virtualenv

# Run diagnostics
run_diagnostics


