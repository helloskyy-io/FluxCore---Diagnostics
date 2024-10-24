import subprocess
import json

def check_gpus(test_config):
    try:
        # Run nvidia-smi to query GPU names
        result = subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            # If nvidia-smi fails, return a message indicating no GPUs detected or another issue.
            return test_config["fail_result"], "No GPUs detected or nvidia-smi not installed.", test_config["colors"]["fail"]

        # Split the result into a list of GPU names
        gpu_list = result.stdout.strip().splitlines()

        if not gpu_list:
            return test_config["fail_result"], "No GPUs detected.", test_config["colors"]["fail"]

        # Count the occurrences of each GPU type
        gpu_count = {}
        for gpu in gpu_list:
            gpu_count[gpu] = gpu_count.get(gpu, 0) + 1

        # Format the result to show the GPU type and count
        gpu_info = "\n".join([f"{gpu}: {count}" for gpu, count in gpu_count.items()])

        # Return the result with green color (pass)
        return gpu_info, test_config["pass_recommendation"], test_config["colors"]["pass"]

    except Exception as e:
        return test_config["fail_result"], str(e), test_config["colors"]["fail"]
