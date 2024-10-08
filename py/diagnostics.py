import json
import subprocess
from rich.console import Console
from rich.table import Table

# Load the configuration from config.json
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)

console = Console()

def check_nvidia_driver_version():
    # Get the installed Nvidia driver version
    try:
        result = subprocess.run(['nvidia-smi', '--query-gpu=driver_version', '--format=csv,noheader'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installed_version = result.stdout.strip()

        # Check if the command was successful
        if result.returncode != 0 or not installed_version:
            return "Failed", config["nvidia_driver"]["fail_recommendation"]
        
        # Compare the installed version with the expected version from config.json
        expected_version = config["nvidia_driver"]["expected_version"]
        if installed_version == expected_version:
            return "Installed", config["nvidia_driver"]["pass_recommendation"]
        else:
            return "Failed", f"Installed version {installed_version}. Please purge and reinstall Nvidia driver {expected_version}."
    except Exception as e:
        return "Failed", str(e)

def run_diagnostics():
    table = Table(title="Diagnostics Results")

    # Define table columns
    table.add_column("Test", justify="left")
    table.add_column("Result", justify="center")
    table.add_column("Recommendation", justify="center")

    # Nvidia driver check
    test_name = f'{config["nvidia_driver"]["test"]} {config["nvidia_driver"]["expected_version"]}'
    result, recommendation = check_nvidia_driver_version()

    # Add the result to the table
    table.add_row(test_name, result, recommendation)

    # Print the table to the console
    console.print(table)

# Run diagnostics
run_diagnostics()

