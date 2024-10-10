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
    echo "Checking system dependencies..."
    if ! dpkg -s build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev >/dev/null 2>&1; then
        echo "System dependencies missing. Installing..."
        sudo apt-get update
        sudo apt-get install -y \
            libssl-dev zlib1g-dev libbz2-dev \
            libreadline-dev libsqlite3-dev libffi-dev \
            liblzma-dev libncurses5-dev libncursesw5-dev \
            build-essential
        if ! dpkg -s build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev >/dev/null 2>&1; then
            echo "Error: Failed to install required system dependencies."
            exit 1
        else
            echo "System dependencies successfully installed."
        fi
    else
        echo "System dependencies are already installed."
    fi
}

# Function to install pyenv if not already installed
install_pyenv() {
    export PYENV_ROOT="$HOME/.pyenv"
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Installing pyenv..."
        export PATH="$PYENV_ROOT/bin:$PATH"
        sudo rm -rf /home/fluxuser/.pyenv
        curl https://pyenv.run | bash
        if [ $? -ne 0 ]; then
            echo "Error: pyenv installation failed."
            exit 1
        fi
        echo "pyenv installation complete."
    else
        echo "pyenv is already installed."
    fi

    # Set up pyenv hooks
    if [ ! -d "$PYENV_ROOT/pyenv-hooks" ]; then
        mkdir -p "$PYENV_ROOT/pyenv-hooks"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create pyenv hooks directory."
            exit 1
        fi
    fi
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' > "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"
    chmod +x "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"
    mkdir -p "$PYENV_ROOT/plugins/pyenv-hooks"
    echo 'source "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"' > "$PYENV_ROOT/plugins/pyenv-hooks/activate"
}

# Function to install Python 3.12 if not installed
install_python() {
    if ! pyenv versions | grep -q "3.12.0"; then
        pyenv install 3.12.0
        if ! pyenv versions | grep -q "3.12.0"; then
            echo "Error: Python 3.12.0 installation failed. Exiting..."
            exit 1
        fi
    fi
}

# Function to create a virtual environment if it doesn't exist
create_virtualenv() {
    if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
        pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
        if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
            echo "Error: Failed to create virtual environment. Exiting..."
            exit 1
        fi
    else
        echo "Virtual environment already exists."
    fi
}

# Function to install Python packages inside the virtualenv
install_python_packages() {
    pyenv activate fluxcore-diagnostics-env
    
    # Debug output to show the virtual environment activation
    if [ $? -ne 0 ]; then
        echo "Error: Failed to activate the virtual environment."
        exit 1
    else
        echo "Virtual environment activated successfully."
    fi

    # Upgrade pip
    echo "Upgrading pip..."
    pip install --upgrade pip
    
    # Check if the pinned_reqs.txt file exists and has content
    if [ ! -f /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt ]; then
        echo "Error: pinned_reqs.txt file not found!"
        exit 1
    fi

    if [ ! -s /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt ]; then
        echo "Error: pinned_reqs.txt is empty!"
        exit 1
    fi
    
    # Display the contents of the pinned_reqs.txt file for debugging
    echo "Contents of pinned_reqs.txt:"
    cat /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

    # Loop through each line in the pinned_reqs.txt file
    while read -r requirement; do
        if [ -n "$requirement" ]; then  # Add a check to skip empty lines
            echo "Checking if $requirement is already installed..."
            if ! pip show "$requirement" &> /dev/null; then
                echo "Installing $requirement..."
                pip install "$requirement"
                if ! pip show "$requirement" &> /dev/null; then
                    echo "Error: Failed to install $requirement. Exiting..."
                    exit 1
                else
                    echo "$requirement installed successfully."
                fi
            else
                echo "$requirement is already installed."
            fi
        else
            echo "Skipped an empty line in pinned_reqs.txt."
        fi
    done < /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

    echo "All required packages processed."
}


# Function to activate the virtualenv and run diagnostics
run_diagnostics() {
    pyenv activate fluxcore-diagnostics-env
    if [ $? -ne 0 ]; then
        echo "Error: Failed to activate the virtual environment. Exiting..."
        exit 1
    fi
    python /home/fluxuser/FluxCore-Diagnostics/main.py
}

# Main Execution Flow
sudo_check

cd /home/fluxuser

# Initialize pyenv for the session once
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Check if Python 3.12 is installed via pyenv. If not, install dependencies and pyenv
if ! pyenv versions | grep -q "3.12.0"; then
    install_dependencies
    install_pyenv
    install_python
fi

# Create virtual environment if not already created
create_virtualenv

# Install necessary Python packages inside the virtualenv
install_python_packages

# Run diagnostics
run_diagnostics





