import subprocess

# Function to check if CUDA is installed and the version is correct
def check_cuda_installed(test_config):
    try:
        # Run the command to get CUDA version
        result = subprocess.run(['nvcc', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output = result.stdout.strip()

        # Check if the command was successful and parse the version
        if result.returncode != 0 or "Cuda compilation tools" not in output:
            return test_config["fail_result"], test_config["fail_recommendation"], test_config["colors"]["fail"]

        # Extract the version from the output (assuming format "Cuda compilation tools, release X.Y, VX.Y.Z")
        for line in output.split('\n'):
            if "Cuda compilation tools" in line:
                installed_version = line.split(",")[1].split()[1]  # Extracts "X.Y" version

                # Compare the installed version with the expected version from config.json
                expected_version = test_config["expected_version"]
                if installed_version.startswith(expected_version):
                    return test_config["pass_result"], test_config["pass_recommendation"], test_config["colors"]["pass"]
                else:
                    return test_config["fail_result"], f"Installed version {installed_version}. {test_config['fail_recommendation']}", test_config["colors"]["fail"]
    except Exception as e:
        return test_config["fail_result"], str(e), test_config["colors"]["fail"]
