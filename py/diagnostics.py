import subprocess
import tkinter as tk
import time

# Function to check if Nvidia 550 drivers are installed
def check_nvidia_driver():
    try:
        # Run nvidia-smi command and capture output
        output = subprocess.check_output(["nvidia-smi"], universal_newlines=True)
        if "550" in output:  # Simplified check
            return True
        else:
            return False
    except subprocess.CalledProcessError:
        return False

# Function to run diagnostics and update UI
def run_diagnostics():
    label.config(text="Checking Nvidia 550 drivers...")
    window.update()
    time.sleep(1)  # Delay to give user time to read

    if check_nvidia_driver():
        button.config(bg="green", text="Success")
    else:
        button.config(bg="red", text="Failure")
    
    label.config(text="Nvidia 550 Driver Check Completed")

# Setup Tkinter window
window = tk.Tk()
window.title("Diagnostics")

label = tk.Label(window, text="Running diagnostics...", font=("Helvetica", 16))
label.pack(pady=20)

button = tk.Button(window, text="Pending", font=("Helvetica", 16), width=20, height=2)
button.pack(pady=10)

# Run diagnostics after window loads
window.after(1000, run_diagnostics)  # Start diagnostics after a 1 second delay

window.mainloop()
