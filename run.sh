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

    # Check if the required packages are installed
    if ! dpkg -s build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev >/dev/null 2>&1; then
        echo "System dependencies missing. Installing..."

        # Update and install the required dependencies
        sudo apt-get update
        sudo apt-get install -y \
            libssl-dev zlib1g-dev libbz2-dev \
            libreadline-dev libsqlite3-dev libffi-dev \
            liblzma-dev libncurses5-dev libncursesw5-dev \
            build-essential

        # Recheck if the dependencies were successfully installed
        if ! dpkg -s build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev >/dev/null 2>&1; then
            echo "Error: Failed to install required system dependencies."
            exit 1  # Exit with an error if installation failed
        else
            echo "System dependencies successfully installed."
        fi

    else
        echo "System dependencies are already installed."
    fi
}


# Function to install pyenv as fluxuser if not already installed
install_pyenv() {
    sudo -i -u fluxuser bash << 'EOF'

    export PYENV_ROOT="$HOME/.pyenv"
    
    # Check if pyenv is already installed
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv not found. Installing pyenv..."

        # Temporarily add pyenv to PATH for installation
        export PATH="$PYENV_ROOT/bin:$PATH"
        echo "Temporarily added pyenv to PATH for installation."

        # Remove any existing pyenv directory to avoid conflicts
        sudo rm -rf /home/fluxuser/.pyenv
        echo "Removed any previous pyenv installation."

        # Install pyenv
        curl https://pyenv.run | bash
        if [ $? -ne 0 ]; then
            echo "Error: pyenv installation failed."
            exit 1
        fi
        echo "pyenv installation complete."

    else
        echo "pyenv is already installed."
    fi

    # Set up pyenv hooks to manage PATH automatically
    if [ ! -d "$PYENV_ROOT/pyenv-hooks" ]; then
        echo "Setting up pyenv hooks..."
        mkdir -p "$PYENV_ROOT/pyenv-hooks"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create pyenv hooks directory."
            exit 1
        fi
    fi

    # Create the pyenv hook script to dynamically adjust PATH
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' > "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"
    chmod +x "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to configure pyenv PATH hook."
        exit 1
    fi
    echo "pyenv PATH hook configured."

    # Ensure pyenv hook is sourced upon environment activation
    mkdir -p "$PYENV_ROOT/plugins/pyenv-hooks"
    echo 'source "$PYENV_ROOT/pyenv-hooks/fluxcore-diagnostics-path.sh"' > "$PYENV_ROOT/plugins/pyenv-hooks/activate"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create pyenv activation hook."
        exit 1
    fi
    echo "pyenv environment activation hook created."

    # Check if the hook is working by testing pyenv
    echo "Testing pyenv availability..."
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    if command -v pyenv &> /dev/null; then
        echo "pyenv is successfully available in the current session."
    else
        echo "Error: pyenv is NOT available. Exiting setup."
        exit 1
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

    # Check if Python 3.12.0 is installed using pyenv
    if ! pyenv versions | grep -q "3.12.0"; then
        echo "Python 3.12.0 is not installed. Installing Python 3.12..."
        pyenv install 3.12.0

        # Recheck if Python 3.12.0 is installed after the installation attempt
        if ! pyenv versions | grep -q "3.12.0"; then
            echo "Error: Python 3.12.0 installation failed. Exiting..."
            exit 1  # Exit with an error if Python 3.12.0 is still not found
        else
            echo "Python 3.12.0 successfully installed."
        fi
    else
        echo "Python 3.12.0 is already installed."
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

        # Verify if the virtual environment was successfully created
        if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
            echo "Error: Failed to create virtual environment 'fluxcore-diagnostics-env'. Exiting..."
            exit 1  # Exit with error if the virtual environment is not found
        else
            echo "Virtual environment 'fluxcore-diagnostics-env' successfully created."
        fi
    else
        echo "Virtual environment 'fluxcore-diagnostics-env' already exists."
    fi
EOF
}


# Function to install Python packages inside the virtualenv
install_python_packages() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="\$HOME/.pyenv"
    export PATH="\$PYENV_ROOT/bin:\$PATH"
    eval "\$(pyenv init --path)"
    eval "\$(pyenv init -)"
    pyenv activate fluxcore-diagnostics-env

    # Upgrade pip
    pip install --upgrade pip

    # Check and install required Python packages from pinned_reqs.txt
    while read -r requirement; do
        # Check if package is already installed
        if ! pip show "\$requirement" &> /dev/null; then
            echo "Installing \$requirement..."
            pip install "\$requirement"

            # Verify the package is installed successfully
            if ! pip show "\$requirement" &> /dev/null; then
                echo "Error: Failed to install \$requirement. Exiting..."
                exit 1  # Exit with error if the package is not installed
            else
                echo "\$requirement installed successfully."
            fi
        else
            echo "\$requirement is already installed."
        fi
    done < /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt
EOF
}


# Function to activate the virtualenv and run diagnostics
run_diagnostics() {
    sudo -i -u fluxuser bash << 'EOF'
    export PYENV_ROOT="\$HOME/.pyenv"
    export PATH="\$PYENV_ROOT/bin:\$PATH"
    eval "\$(pyenv init --path)"
    eval "\$(pyenv init -)"
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    
    # Activate the virtual environment
    if pyenv activate fluxcore-diagnostics-env &> /dev/null; then
        echo "Successfully activated the virtual environment."
    else
        echo "Error: Failed to activate the virtual environment. Exiting..."
        exit 1  # Exit with error if the virtual environment activation fails
    fi

    echo "Running diagnostics..."
    python /home/fluxuser/FluxCore-Diagnostics/main.py
EOF
}


# Main Execution Flow
sudo_check

# Check if Python 3.12 is installed via pyenv. If not, install dependencies and pyenv
sudo -i -u fluxuser bash << 'EOF'
if ! pyenv versions | grep -q "3.12.0"; then
    echo "Python 3.12.0 is not installed. Proceeding with installation..."
    exit 1  # Signal that dependencies and pyenv need to be installed
else
    echo "Python 3.12.0 is already installed."
    exit 0  # Python is installed, no further action needed
fi
EOF

if [ $? -ne 0 ]; then
    install_dependencies
    install_pyenv
    install_python
else
    echo "All necessary components are already installed."
fi

# Create virtual environment if not already created
create_virtualenv

# Install necessary Python packages inside the virtualenv
install_python_packages

# Run diagnostics
run_diagnostics




