import subprocess
import platform
import json

# Load configuration for the host_info_test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

def check_host_info(test_config):
    try:
        # Get Ubuntu version and type (server or desktop)
        version_info = subprocess.run(['lsb_release', '-d'], stdout=subprocess.PIPE, text=True).stdout.strip()
        if 'server' in version_info.lower():
            ubuntu_type = "Server"
        else:
            ubuntu_type = "Desktop"
        ubuntu_version = version_info.split(':')[1].strip()

        # Get the kernel version
        kernel_version = platform.release()

        # Return pass result with green color
        result = f"Ubuntu {ubuntu_version} ({ubuntu_type}), Kernel {kernel_version}"
        return result, test_config["pass_recommendation"], result_colors["pass"]

    except Exception as e:
        # Return fail result with red color
        return test_config["fail_result"], str(e), result_colors["fail"]


