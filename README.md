# VMFC (Virtual Machine Firecracker) Installer & Diagnostic Tools

> **Note:** This toolset is specifically designed and optimized for **Arch Linux** host systems. 

## Overview
This repository provides the deployment and observability modules for `vmfc`, a lightweight Firecracker microVM management tool. The ecosystem consists of a system installation script (`install.sh`) and a diagnostic health-check utility (`doctor.sh`).

## Quick Start (Installation)
You can securely download and execute the installer directly in a single command. Because the script provisions binaries to the system `PATH` and requires root permissions, it must be piped to `sudo bash`:

```bash
curl -fsSL https://raw.githubusercontent.com/gni/vmfc/main/install.sh | sudo bash
```

## Execution Flow
1. **Installation:** `install.sh` securely fetches the primary `vmfc` executable from the remote repository, validates system permissions, and provisions the binary into the system `PATH`.
2. **Diagnostics:** `doctor.sh` audits the host environment for virtualization readiness, dependencies, and synchronization state against the upstream repository.

## Dependencies
- **OS:** Arch Linux
- `bash` (v4.0+)
- `curl`
- `coreutils` (for `sha256sum`, `chmod`, `chown`)
- KVM kernel module enabled (`/dev/kvm`)
