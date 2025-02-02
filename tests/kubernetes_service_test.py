import subprocess
import json
import glob
import os

# Load configuration for the Kubernetes service test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

def find_kubectl():
    """Dynamically find the latest kubectl binary in RKE2 installation."""
    search_path = "/var/lib/rancher/rke2/data/"
    kubectl_paths = glob.glob(f"{search_path}*/bin/kubectl")

    if not kubectl_paths:
        return None  # kubectl not found

    # Sort by modification time (latest version first)
    kubectl_paths.sort(key=os.path.getmtime, reverse=True)
    return kubectl_paths[0]  # Return the latest kubectl found

def check_kubernetes_client(test_config):
    kubectl_path = find_kubectl()
    
    if not kubectl_path:
        return test_config["fail_result"], "kubectl not found", result_colors["fail"]

    try:
        # Run kubectl from the dynamically found path
        result = subprocess.run([kubectl_path, 'version', '--client'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        kubectl_output = result.stdout.strip()

        # Check if kubectl is responsive
        if "Client Version" in kubectl_output:
            return test_config["pass_result"], test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]

