import subprocess

def check_fluxcore_version(test_config, result_colors):
    try:
        # Get the installed version
        installed_version_result = subprocess.run(['/home/fluxuser/fluxcore-linux-amd64', '-version'],
                                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installed_version = installed_version_result.stdout.strip()

        # Get the latest release version
        latest_version_result = subprocess.run(['/home/fluxuser/fluxcore-linux-amd64', '-latest'],
                                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        latest_version = latest_version_result.stdout.strip()

        # Check if both commands were successful
        if installed_version_result.returncode == 0 and latest_version_result.returncode == 0:
            if installed_version == latest_version:
                return f"FluxCore {installed_version}", test_config["pass_recommendation"], result_colors["pass"]
            else:
                return f"FluxCore {installed_version} (outdated)", f"Please update to {latest_version}", result_colors["fail"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]

