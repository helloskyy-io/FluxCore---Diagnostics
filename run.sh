#!/bin/bash

# Check if tkinter is installed
if ! python3 -c "import tkinter" &> /dev/null; then
  echo "Tkinter not found. Installing it now..."
  sudo apt-get update
  sudo apt-get install -y python3-tk
else
  echo "Tkinter is already installed."
fi

# Define the directory paths at the top
FLUXCORE_PATH="/home/fluxuser/FluxCore-Diagnostics"

# Use the environment variable throughout the script
sudo python3 $FLUXCORE_PATH/py/diagnostics.py
