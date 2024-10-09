import subprocess

# Function to check Nvidia driver version
def check_nvidia_driver_version(test_config):
    try:
        # Get the installed Nvidia driver version
        result = subprocess.run(['nvidia-smi', '--query-gpu=driver_version', '--format=csv,noheader'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installed_version = result.stdout.strip()

        # Check if the command was successful
        if result.returncode != 0 or not installed_version:
            return test_config["fail_result"], test_config["fail_recommendation"], test_config["colors"]["fail"]
        
        # Compare the installed version with the expected version from the JSON config
        expected_version = test_config["expected_version"]
        if installed_version.startswith(expected_version):
            return test_config["pass_result"], test_config["pass_recommendation"], test_config["colors"]["pass"]
        else:
            return test_config["fail_result"], f"Installed version {installed_version}. {test_config['fail_recommendation']}", test_config["colors"]["fail"]
    except Exception as e:
        return test_config["fail_result"], str(e), test_config["colors"]["fail"]
