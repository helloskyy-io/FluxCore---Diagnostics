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

# Function to run diagnostics after environment activation
run_diagnostics() {
    python /home/fluxuser/FluxCore-Diagnostics/main.py
    if [ $? -ne 0 ]; then
        echo "Error: Diagnostics script failed."
        exit 1
    fi
}

# Main Execution Flow
sudo_check

cd /home/fluxuser

# Check if virtual environment exists, if not create it
if [ ! -d "fluxcore-diagnostics-env" ]; then
    python3 -m venv fluxcore-diagnostics-env
fi

# Activate the virtual environment
source fluxcore-diagnostics-env/bin/activate

# Upgrade pip and install requirements
pip install --upgrade pip
pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

# Run diagnostics
run_diagnostics
