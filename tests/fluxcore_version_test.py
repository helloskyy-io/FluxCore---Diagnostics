import subprocess
import json

def check_fluxcore_version(test_config, result_colors):
    try:
        # Run the command to check the installed version
        installed_version_result = subprocess.run(['/home/fluxuser/fluxcore-linux-amd64', '-version'],
                                                  stdout=subprocess.PIPE, text=True)
        installed_version = installed_version_result.stdout.strip()

        # Run the command to get the latest version
        latest_version_result = subprocess.run(['/home/fluxuser/fluxcore-linux-amd64', '-latest'],
                                               stdout=subprocess.PIPE, text=True)
        latest_version = latest_version_result.stdout.strip().splitlines()[-1]  # Get the actual version from the last line

        # Compare versions and determine pass/fail
        if installed_version == latest_version:
            return f"FluxCore {installed_version}", test_config["pass_recommendation"], result_colors["pass"]
        else:
            return f"FluxCore {installed_version} (outdated)", test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]


