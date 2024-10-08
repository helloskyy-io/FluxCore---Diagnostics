from rich.console import Console
from rich.table import Table
import subprocess

console = Console()

def check_nvidia_driver():
    try:
        # Run a simple shell command to check if the Nvidia driver is installed
        result = subprocess.run(['nvidia-smi'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode == 0:
            return True, None  # Driver is installed
        else:
            return False, result.stderr.decode('utf-8')  # Return error message
    except Exception as e:
        return False, str(e)  # Catch and return the exception message

def main():
    console.print("[bold cyan]Running diagnostics...[/bold cyan]")

    # Create a table for visualization
    table = Table(title="Diagnostics Results")

    table.add_column("Test", justify="left", style="cyan", no_wrap=True)
    table.add_column("Result", justify="right", style="green")

    # Run the Nvidia driver check
    nvidia_installed, error_message = check_nvidia_driver()
    if nvidia_installed:
        table.add_row("Nvidia Driver", "[green]Installed[/green]")
    else:
        table.add_row("Nvidia Driver", f"[red]Not Installed: {error_message}[/red]")

    console.print(table)

if __name__ == "__main__":
    main()

