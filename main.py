import json
from rich.console import Console
from rich.table import Table
from tests.check_host_info import check_host_info
from tests.gpu_driver_tests import check_nvidia_driver_version
from tests.cuda_installed_test import check_cuda_installed
from tests.nvidia_kernel_modules import check_nvidia_kernel_modules
from tests.fluxcore_service_test import check_fluxcore_service
from tests.fluxcore_webserver_test import check_webserver
from tests.fluxcore_version_test import check_fluxcore_version
from tests.rancher_service_test import check_rancher_service
from tests.kubernetes_service_test import check_kubernetes_client

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
        if test["type"] == "host_info_test":
            test_name = test["description"]
            result, recommendation, color = check_host_info(test)  # Pass the test config here
        elif test["type"] == "gpu_driver_test":
            test_name = f'{test["description"]} {test["expected_version"]}'
            result, recommendation, color = check_nvidia_driver_version(test)
        elif test["type"] == "cuda_installed_test":
            test_name = f'{test["description"]} {test["expected_version"]}'
            result, recommendation, color = check_cuda_installed(test)
        elif test["type"] == "nvidia_kernel_modules":
            test_name = test["description"]
            result, recommendation, color = check_nvidia_kernel_modules(test)
        elif test["type"] == "fluxcore_version_test":
            test_name = test["description"]
            result, recommendation, color = check_fluxcore_version(test, result_colors)  # Pass result_colors here
        elif test["type"] == "fluxcore_service_test":
            test_name = test["description"]
            result, recommendation, color = check_fluxcore_service(test)
        elif test["type"] == "fluxcore_webserver_test":
            test_name = test["description"]
            result, recommendation, color = check_webserver(test)
        elif test["type"] == "rancher_service_test":
            test_name = test["description"]
            result, recommendation, color = check_rancher_service(test)
        elif test["type"] == "kubernetes_service_test":
            test_name = test["description"]
            result, recommendation, color = check_kubernetes_client(test)

        # Color the result based on pass or fail
        result_colored = f'[{color}]{result}[/{color}]'

        # Add the result to the table
        table.add_row(test_name, result_colored, recommendation)

    # Print the table to the console
    console.print(table)


# Run diagnostics
if __name__ == "__main__":
    run_diagnostics()

