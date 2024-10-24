import subprocess
import platform

def check_host_info():
    # Get Ubuntu version and type (server or desktop)
    try:
        version_info = subprocess.run(['lsb_release', '-d'], stdout=subprocess.PIPE, text=True).stdout.strip()
        if 'server' in version_info.lower():
            ubuntu_type = "Server"
        else:
            ubuntu_type = "Desktop"
        ubuntu_version = version_info.split(':')[1].strip()
    except Exception as e:
        ubuntu_version = "Unknown"
        ubuntu_type = "Unknown"

    # Get the kernel version
    kernel_version = platform.release()

    return f"Ubuntu {ubuntu_version} ({ubuntu_type})", f"Kernel {kernel_version}"

