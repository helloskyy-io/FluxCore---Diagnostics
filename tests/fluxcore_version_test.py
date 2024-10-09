import subprocess
import json

# Load configuration for the fluxcore_version_test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

def check_fluxcore_version(test_config):
    try:
        # Run the FluxCore version command
        result = subprocess.run(['/home/fluxuser/fluxcore-linux-amd64', '-version'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installed_version = result.stdout.strip()

        # Check if the command was successful
        if result.returncode == 0 and installed_version:
            return f"FluxCore {installed_version}", test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]
