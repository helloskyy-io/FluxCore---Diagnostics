import json
from rich.console import Console
from rich.table import Table
from tests.gpu_driver_tests import check_nvidia_driver_version
from tests.cuda_installed_test import check_cuda_installed
from tests.nvidia_kernel_modules import check_nvidia_kernel_modules

# Load the configuration from config.json
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)

console = Console()

# Extract table settings from the JSON
result_colors = config["table_settings"]["result_colors"]
header_color = config["table_settings"]["header_color"]

def run_diagnostics():
    table = Table(title="Diagnostics Results")

    # Define table columns with header color
    table.add_column(f"[{header_color}]Test[/]", justify="left")
    table.add_column(f"[{header_color}]Result[/]", justify="center")
    table.add_column(f"[{header_color}]Recommendation[/]", justify="center")

    # Run diagnostics for each test in the config
    for test in config["tests"]:
        test_name = f'{test["description"]}'
        if test["type"] == "gpu_driver_test":
            result, recommendation, color = check_nvidia_driver_version(test)
        elif test["type"] == "cuda_installed_test":
            result, recommendation, color = check_cuda_installed(test)
        elif test["type"] == "nvidia_kernel_modules":
            result, recommendation, color = check_nvidia_kernel_modules(test)

        # Color the result based on pass or fail
        result_colored = f'[{color}]{result}[/{color}]'

        # Add the result to the table
        table.add_row(test_name, result_colored, recommendation)

    # Print the table to the console
    console.print(table)

# Run diagnostics
if __name__ == "__main__":
    run_diagnostics()
