import json
from rich.console import Console
from rich.table import Table
import subprocess

console = Console()

# Load configuration from JSON file
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)

def check_nvidia_driver(version):
    try:
        # Run a shell command to check for Nvidia driver version
        result = subprocess.run(['nvidia-smi'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if version in result.stdout:
            return True
        else:
            return False
    except Exception as e:
        return False

def main():
    console.print("[bold cyan]Running diagnostics...[/bold cyan]")
    table = Table(title="Diagnostics Results")

    table.add_column("Test", justify="left", style="cyan", no_wrap=True)
    table.add_column("Result", justify="center", style="green")
    table.add_column("Recommendation", justify="left", style="magenta")

    # Nvidia driver check
    driver_version = config['nvidia_driver_version']
    nvidia_installed = check_nvidia_driver(driver_version)
    if nvidia_installed:
        result = "[green]Installed[/green]"
        recommendation = config['recommended_action']['success']
    else:
        result = "[red]Failed[/red]"
        recommendation = config['recommended_action']['failure']

    table.add_row(f"Testing for Nvidia Driver {driver_version}", result, recommendation)

    console.print(table)

if __name__ == "__main__":
    main()

