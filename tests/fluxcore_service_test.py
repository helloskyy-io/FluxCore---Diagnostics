import subprocess
import json

# Load configuration for the fluxcore_service_test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

def check_fluxcore_service(test_config):
    try:
        # Run the systemctl command to check the service status
        result = subprocess.run(['systemctl', 'is-active', f'{test_config["service_name"]}.service'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        service_status = result.stdout.strip()

        # Check if the service is running
        if service_status == "active":
            return test_config["pass_result"], test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]
