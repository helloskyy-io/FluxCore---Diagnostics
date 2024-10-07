#!/bin/bash


### check that nvidia drivers and cuda are properly installed ###
# Check if Nvidia drivers are installed and working
echo "Checking Nvidia drivers and CUDA installation..."
echo "Running nvidia-smi..."
nvidia-smi

# Check CUDA version
echo "Checking CUDA version..."
nvcc --version

# # Check for CUDA libraries
# echo "Checking for CUDA libraries..."
# ldconfig -p | grep cuda

# # Check for cuDNN (if applicable)
# echo "Checking for cuDNN version..."
# cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2

# Check if Nvidia kernel modules are loaded
echo "Checking Nvidia kernel modules..."
lsmod | grep nvidia

# Optionally, run CUDA sample test (uncomment if desired)
# echo "Running CUDA sample deviceQuery..."
# cd /usr/local/cuda/samples/1_Utilities/deviceQuery/ && make && ./deviceQuery

echo "Nvidia and CUDA checks completed!"

 

### Ensure FluxCore service is running ###
# Check if FluxCore is running as a systemd service
echo "Checking FluxCore service status..."
fluxcore_service_status=$(systemctl is-active fluxcore.service)

if [ "$fluxcore_service_status" = "active" ]; then
    echo "FluxCore service is running"
else
    echo "FluxCore service is not running. Checking for running process..."

    # Check if FluxCore process is running
    fluxcore_process=$(pgrep -f fluxcore-linux-amd64)
    
    if [ -n "$fluxcore_process" ]; then
        echo "FluxCore process is running with PID: $fluxcore_process"
    else
        echo "FluxCore is not running"
    fi
fi




### check that rancher and kubectl are responsive ###
# Check rke2-server service status (Rancher server)
echo "Checking rke2-server service status..."
rke2_server_status=$(systemctl is-active rke2-server.service)

if [ "$rke2_server_status" = "active" ]; then
    echo "rke2-server service is running"
else
    echo "rke2-server service is not running"
fi

# Check rke2-agent service status (Rancher agent)
echo "Checking rke2-agent service status..."
rke2_agent_status=$(systemctl is-active rke2-agent.service)

if [ "$rke2_agent_status" = "active" ]; then
    echo "rke2-agent service is running"
else
    echo "rke2-agent service is not running"
fi

# Check if kubectl is responsive
echo "Checking kubectl..."
kubectl_version=$(/var/lib/rancher/rke2/data/v1.28.10-rke2r1-4fdaccf43ed6/bin/kubectl version --client 2>&1)

if [[ $kubectl_version == *"Client Version"* ]]; then
    echo "kubectl is functioning"
else
    echo "kubectl is not responsive"
fi




### Check if the web server is up on port 18180 ###
# Function to get the system's IP address
get_system_ip() {
    ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1
}

# Check if the web server is up on localhost
response_localhost=$(curl -L --write-out "%{http_code}" --silent --output /dev/null http://localhost:18180)

# Get system IP and check if the web server is up on system IP
system_ip=$(get_system_ip)
response_system_ip=$(curl -L --write-out "%{http_code}" --silent --output /dev/null http://$system_ip:18180)

# Output the results
echo "Checking web server on localhost (127.0.0.1): HTTP status code: $response_localhost"
echo "Checking web server on system IP ($system_ip): HTTP status code: $response_system_ip"

# Determine if either check is successful
if [ "$response_localhost" -eq 200 ] || [ "$response_system_ip" -eq 200 ]; then
    echo "Web server is running and responsive on either localhost or system IP"
else
    echo "Web server is down or unresponsive on both localhost and system IP"
fi




### Check current FluxCore version vs. latest FLuxcore version ###

# Check installed version
echo "Checking installed FluxCore version..."
installed_version=$(sudo /home/fluxuser/fluxcore-linux-amd64 -version)

# Fetch the latest version from the website
# latest_version=$(curl -s https://example.com/fluxcore/releases | grep -oP 'Version \K[\d.]+')

echo "Installed version: $installed_version"
# echo "Latest version: $latest_version"

# Compare versions
# if [ "$installed_version" != "$latest_version" ]; then
#     echo "A new version of FluxCore is available: $latest_version"
#     # Optionally recommend running the update
# else
#     echo "FluxCore is up to date."
# fi
