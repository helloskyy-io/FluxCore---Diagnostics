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
	echo -e ""
        exit 1
    fi
 fi
 echo -e ""
}



# Check if sudo is required
sudo_check

# Switch to fluxuser and perform the rest of the operations
sudo -u fluxuser bash << 'EOF'

# Set paths for pyenv and virtual environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Install pyenv if not already installed
if ! command -v pyenv &> /dev/null; then
  echo "pyenv not found. Installing pyenv..."
  curl https://pyenv.run | bash

  # Add pyenv to bashrc for future shells
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc

  # Reload shell
  source ~/.bashrc
fi

# Install Python 3.12 if not installed
if ! pyenv versions | grep -q "3.12.0"; then
  echo "Installing Python 3.12..."
  pyenv install 3.12.0
fi

# Create a virtual environment if it doesn't exist
if [ ! -d "$HOME/.pyenv/versions/fluxcore-diagnostics-env" ]; then
  echo "Creating virtual environment..."
  pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
fi

# Activate the virtual environment
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
pyenv activate fluxcore-diagnostics-env

# Install required Python packages
pip install --upgrade pip
pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

# Run the diagnostics Python script
python /home/fluxuser/FluxCore-Diagnostics/py/diagnostics.py

EOF
