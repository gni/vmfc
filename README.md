# VMFC (Virtual Machine Firecracker) Installer & Diagnostic Tools

> **Note:** This toolset is specifically designed and optimized for **Arch Linux** host systems. 

## Overview
This repository provides the deployment and observability modules for `vmfc`, a lightweight, shell-based Firecracker microVM management tool. 

While Firecracker provides incredibly fast and secure hardware virtualization, manually configuring network taps, building root filesystems, extracting kernels, and setting up `jailer` environments can be highly complex. `vmfc` abstracts this process, allowing you to bootstrap, provision, and securely connect to Arch Linux microVMs in seconds using simple CLI commands.

## Features
- **Automated Provisioning:** Builds raw Ext4 filesystems, injects VirtIO drivers, and extracts kernels automatically.
- **Secure by Default:** Runs all microVMs through Firecracker's `jailer` for robust cgroup/namespace isolation.
- **Dynamic Networking:** Automatically manages a shared network bridge (`fcbr0`), creates unique TAP devices per VM, and dynamically generates deterministic IP/MAC addresses based on the VM name.
- **Zero-Trust SSH:** Automatically generates and provisions ED25519 SSH keys for seamless, passwordless entry.

---

## Quick Start (Installation)
You can securely download and execute the installer directly in a single command. Because the script provisions binaries to the system `PATH` and requires root permissions, it must be piped to `sudo bash`:

```bash
curl -fsSL https://raw.githubusercontent.com/gni/vmfc/main/install.sh | sudo bash
```

### 1. Environment Bootstrap
Once installed, you must bootstrap the host environment. This installs required host dependencies (like `e2fsprogs`, `iproute2`, `arch-install-scripts`), downloads the latest Firecracker release, and configures the host network bridge.

```bash
vmfc bootstrap
```

### 2. Diagnostics (Optional but Recommended)
To verify your host is properly configured for virtualization and that you are running the latest version, run:
```bash
doctor.sh
```

---

## Basic Usage

The `vmfc` CLI syntax follows a simple pattern: `vmfc <action> <name> [RAM_MB] [CPUS] [DISK_GB]`

**Create a new microVM:**
*(Example: Creates a VM named "api-node" with 1GB RAM, 2 CPUs, and a 5GB disk)*
```bash
vmfc create api-node 1024 2 5
```

**Start the microVM:**
```bash
vmfc start api-node
```

**Connect via SSH:**
```bash
vmfc ssh api-node
```

**List all microVMs and their status (Running/Stopped, IPs, PIDs):**
```bash
vmfc ls
```

**Stop or Destroy a microVM:**
```bash
vmfc stop api-node    # Gracefully stops the VM and cleans up TAP devices
vmfc delete api-node  # Stops the VM and permanently deletes the disk/files
```

---

## Under the Hood (Architecture)

1. **Installation (`install.sh`):** Securely fetches the primary `vmfc` executable from the remote repository, validates system permissions, and provisions the binary into the system `/usr/local/bin`.
2. **Diagnostics (`doctor.sh`):** Audits the host environment for virtualization readiness (`/dev/kvm`), required dependencies, and synchronization state against the upstream repository.
3. **Guest OS:** Currently, `vmfc` hardcodes **Arch Linux** as the guest operating system. It uses `pacstrap` to build a minimal environment with `systemd-networkd` handling DHCP.
4. **Networking:** The host routes traffic through a masqueraded NAT interface over your WAN connection (default: `wlan0`). VMs are assigned IPs in the `192.168.201.0/24` subnet.

## Dependencies
- **OS:** Arch Linux
- `bash` (v4.0+)
- `curl`
- `coreutils` (for `sha256sum`, `chmod`, `chown`)
- KVM kernel module enabled (`/dev/kvm`)
