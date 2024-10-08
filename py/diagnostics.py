from rich.console import Console
from rich.table import Table
import subprocess

console = Console()

# Function to check Nvidia driver
def check_nvidia_driver(version):
    try:
        # Run a command to check the Nvidia driver version
        result = subprocess.run(['nvidia-smi'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode == 0:
            # Check if the correct version is installed
            if f"Driver Version: {version}" in result.stdout.decode():
                return True, "Installed"
            else:
                return False, "Wrong Version"
        else:
            return False, "Not Installed"
    except Exception as e:
        return False, "Error"

# Main function to run diagnostics
def main():
    console.print("[bold cyan]Running diagnostics...[/bold cyan]")

    # Create a table for visualization
    table = Table(title="Diagnostics Results")
    table.add_column("Test", justify="left", style="cyan", no_wrap=True)
    table.add_column("Result", justify="center", style="green")
    table.add_column("Recommendation", justify="right", style="yellow")

    # Run Nvidia driver check
    version = "550"
    nvidia_installed, nvidia_status = check_nvidia_driver(version)
    
    # Add Nvidia driver test result to the table
    if nvidia_installed:
        table.add_row(f"Testing for Nvidia Driver {version}", "[green]Installed[/green]", "None")
    else:
        if nvidia_status == "Not Installed":
            table.add_row(f"Testing for Nvidia Driver {version}", "[red]Not Installed[/red]", "Please purge and reinstall Nvidia driver 550")
        elif nvidia_status == "Wrong Version":
            table.add_row(f"Testing for Nvidia Driver {version}", "[red]Wrong Version[/red]", "Please purge and reinstall Nvidia driver 550")
        else:
            table.add_row(f"Testing for Nvidia Driver {version}", "[red]Error[/red]", "Check for driver installation issues.")

    # Example for another test to fill out the format:
    table.add_row("Testing for CPU Usage Threshold", "[green]Normal[/green]", "None")

    # Display the table
    console.print(table)

if __name__ == "__main__":
    main()
