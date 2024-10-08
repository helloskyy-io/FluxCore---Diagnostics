#!/bin/bash



# Define the directory path
FLUXCORE_PATH="/home/fluxuser/FluxCore-Diagnostics"

# Check if pyenv is installed
if command -v pyenv &> /dev/null; then
    echo "pyenv is already installed."
else
    echo "pyenv not found. Installing pyenv..."
    
    # Install dependencies for pyenv
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
      libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
      python-openssl git
    
    # Install pyenv
    curl https://pyenv.run | bash

    # Add pyenv to bash profile
    if ! grep -q 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    fi
    
    # Apply changes to the shell
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Check if Python 3.12 is installed through pyenv
if pyenv versions | grep -q "3.12"; then
    echo "Python 3.12 is already installed in pyenv."
else
    echo "Installing Python 3.12 using pyenv..."
    pyenv install 3.12.0
    pyenv global 3.12.0
fi

# Set up the virtual environment if not already present
if [ ! -d "$FLUXCORE_PATH/.venv" ]; then
    echo "Creating Python 3.12 virtual environment..."
    pyenv exec python3 -m venv $FLUXCORE_PATH/.venv
    $FLUXCORE_PATH/.venv/bin/python -m pip install -r $FLUXCORE_PATH/pinned_reqs.txt
else
    echo "Virtual environment already exists."
fi

# Run the Python diagnostics script from the virtual environment
$FLUXCORE_PATH/.venv/bin/python $FLUXCORE_PATH/py/diagnostics.py