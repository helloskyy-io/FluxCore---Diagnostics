import json
import subprocess
from rich.console import Console
from rich.table import Table

# Load the configuration from config.json
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)

console = Console()

# Extract table settings from the JSON
result_colors = config["table_settings"]["result_colors"]

def check_nvidia_driver_version(test_config):
    # Get the installed Nvidia driver version
    try:
        result = subprocess.run(['nvidia-smi', '--query-gpu=driver_version', '--format=csv,noheader'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installed_version = result.stdout.strip()

        # Check if the command was successful
        if result.returncode != 0 or not installed_version:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]
        
        # Compare the installed version with the expected version from the JSON config
        expected_version = test_config["expected_version"]
        if installed_version.startswith(expected_version):
            return test_config["pass_result"], test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], f"Installed version {installed_version}. {test_config['fail_recommendation']}", result_colors["fail"]
    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]

def run_diagnostics():
    table = Table(title="Diagnostics Results")

    # Define table columns
    table.add_column("Test", justify="left")
    table.add_column("Result", justify="center")
    table.add_column("Recommendation", justify="center")

    # Iterate over the tests in the JSON config
    for test in config["tests"]:
        test_name = f'{test["description"]} {test["expected_version"]}'
        result, recommendation, color = check_nvidia_driver_version(test)

        # Color the result based on pass or fail
        result_colored = f'[{color}]{result}[/{color}]'

        # Add the result to the table
        table.add_row(test_name, result_colored, recommendation)

    # Print the table to the console
    console.print(table)

# Run diagnostics
run_diagnostics()
