#!/bin/bash

# Check if pyenv is installed for fluxuser
sudo -u fluxuser bash << 'EOF'
# Use absolute path for pyenv location
export PATH="$HOME/.pyenv/bin:$PATH"

if ! command -v pyenv &> /dev/null; then
  echo "pyenv not found. Installing pyenv..."
  curl https://pyenv.run | bash

  # Add pyenv to bashrc
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc

  # Reload bashrc
  source ~/.bashrc
else
  echo "pyenv is already installed."
fi

# Install Python version 3.12 if not present
if ! pyenv versions | grep -q "3.12"; then
  echo "Installing Python 3.12..."
  pyenv install 3.12.0
fi

# Set up virtual environment for diagnostics
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
pyenv virtualenv 3.12.0 fluxcore-diagnostics-env
pyenv activate fluxcore-diagnostics-env

# Install dependencies from requirements file
pip install -r /home/fluxuser/FluxCore-Diagnostics/pinned_reqs.txt

# Run the diagnostics Python script
python /home/fluxuser/FluxCore-Diagnostics/py/diagnostics.py
EOF
