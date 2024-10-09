import subprocess
import json

# Load configuration for the kubernetes_service_test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

def check_kubernetes_client(test_config):
    try:
        # Check the version of kubectl
        result = subprocess.run(['/var/lib/rancher/rke2/data/v1.28.10-rke2r1-4fdaccf43ed6/bin/kubectl', 'version', '--client'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        kubectl_output = result.stdout.strip()

        # Check if kubectl is responsive by looking for "Client Version" in the output
        if "Client Version" in kubectl_output:
            return test_config["pass_result"], test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]
