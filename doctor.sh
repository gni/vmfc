#!/bin/bash
set -euo pipefail

trap 'echo '{\"level\":\"error\",\"message\":\"Command failed at line $LINENO\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}' >&2; exit 1' ERR INT

readonly VMFC_REPO_URL="https://raw.githubusercontent.com/gni/vmfc/main/vmfc"
readonly BIN_DEST="/usr/local/bin/vmfc"
readonly REQUIRED_CMDS=("curl" "ip" "pacstrap" "mkfs.ext4" "fallocate" "ssh-keygen")

log_info() {
    echo "{\"level\":\"info\",\"message\":\"$1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
}

log_warn() {
    echo "{\"level\":\"warn\",\"message\":\"$1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >&2
}

log_error() {
    echo "{\"level\":\"error\",\"message\":\"$1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >&2
}

check_virtualization() {
    if [[ ! -c "/dev/kvm" ]]; then
        log_error "/dev/kvm is missing. Hardware virtualization is required."
        exit 1
    fi

    if [[ ! -r "/dev/kvm" || ! -w "/dev/kvm" ]]; then
        log_warn "Current user lacks read/write permissions for /dev/kvm."
    else
        log_info "Virtualization interface (/dev/kvm) is accessible."
    fi
}

check_dependencies() {
    local missing=0
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Missing required dependency: $cmd"
            missing=1
        fi
    done

    if [[ "$missing" -eq 1 ]]; then
        log_warn "Some dependencies are missing. Run 'vmfc bootstrap' to install host dependencies."
    else
        log_info "All required host dependencies are present."
    fi
}

check_updates() {
    if [[ ! -f "${BIN_DEST}" ]]; then
        log_warn "vmfc is not installed at ${BIN_DEST}."
        return
    fi

    log_info "Calculating local checksum..."
    local local_hash
    local_hash=$(sha256sum "${BIN_DEST}" | awk '{print $1}')

    log_info "Fetching remote checksum..."
    local remote_hash
    remote_hash=$(curl -fsSL "${VMFC_REPO_URL}" | sha256sum | awk '{print $1}')

    if [[ -z "${remote_hash}" ]]; then
        log_error "Failed to fetch remote checksum for synchronization validation."
        return
    fi

    if [[ "${local_hash}" == "${remote_hash}" ]]; then
        log_info "vmfc is up to date (SHA256: ${local_hash:0:8})."
    else
        log_warn "Update available for vmfc. Run install.sh to upgrade."
    fi
}

main() {
    log_info "Initiating vmfc diagnostic routine..."
    check_virtualization
    check_dependencies
    check_updates
    log_info "Diagnostic routine completed."
}

main "$@"