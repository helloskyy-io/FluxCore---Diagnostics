import subprocess

def check_nvidia_kernel_modules(test_config):
    try:
        # Run the `lsmod` command to get the list of loaded kernel modules
        result = subprocess.run(['lsmod'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        loaded_modules = result.stdout

        # Check if any of the listed Nvidia kernel modules are present
        for module in test_config["modules"]:
            if module in loaded_modules:
                return test_config["pass_result"], test_config["pass_recommendation"], test_config["colors"]["pass"]

        # If none of the key modules are found, return failure
        return test_config["fail_result"], test_config["fail_recommendation"], test_config["colors"]["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), test_config["colors"]["fail"]
