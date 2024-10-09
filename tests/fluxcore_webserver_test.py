import subprocess
import json

# Load configuration for the fluxcore_webserver_test
with open("/home/fluxuser/FluxCore-Diagnostics/config.json") as config_file:
    config = json.load(config_file)
result_colors = config["table_settings"]["result_colors"]

# Function to get the system's IP address
def get_system_ip():
    result = subprocess.run(["ip", "addr", "show"], stdout=subprocess.PIPE, text=True)
    ip_lines = result.stdout.splitlines()
    for line in ip_lines:
        if "inet " in line and "127.0.0.1" not in line:
            return line.split()[1].split("/")[0]
    return None

def check_webserver(test_config):
    try:
        port = test_config["port"]
        # Check if the web server is up on localhost
        response_localhost = subprocess.run(['curl', '-L', '--write-out', '%{http_code}', '--silent', '--output', '/dev/null', f'http://localhost:{port}'], 
                                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        response_localhost = response_localhost.stdout.strip()

        # Check if the web server is up on the system IP
        system_ip = get_system_ip()
        if system_ip:
            response_system_ip = subprocess.run(['curl', '-L', '--write-out', '%{http_code}', '--silent', '--output', '/dev/null', f'http://{system_ip}:{port}'], 
                                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            response_system_ip = response_system_ip.stdout.strip()
        else:
            response_system_ip = "No IP"

        # Determine if either localhost or system IP responds with HTTP 200
        if response_localhost == "200" or response_system_ip == "200":
            return test_config["pass_result"], test_config["pass_recommendation"], result_colors["pass"]
        else:
            return test_config["fail_result"], test_config["fail_recommendation"], result_colors["fail"]

    except Exception as e:
        return test_config["fail_result"], str(e), result_colors["fail"]
