#!/bin/bash
set -euo pipefail

on_error() {
    echo "{\"level\":\"error\",\"message\":\"Command failed at line $1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >&2
    exit 1
}
trap 'on_error $LINENO' ERR INT

readonly VMFC_REPO_URL="https://raw.githubusercontent.com/gni/vmfc/main/vmfc"
readonly BIN_DEST="/usr/local/bin/vmfc"
readonly TMP_DOWNLOAD="/tmp/vmfc_download_$$"

log_info() {
    echo "{\"level\":\"info\",\"message\":\"$1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
}

log_error() {
    echo "{\"level\":\"error\",\"message\":\"$1\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >&2
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "Installation requires root privileges. Please run with sudo."
        exit 1
    fi
}

download_script() {
    log_info "Fetching vmfc payload from upstream..."
    if ! curl -fsSL "${VMFC_REPO_URL}" -o "${TMP_DOWNLOAD}"; then
        log_error "Failed to download vmfc from ${VMFC_REPO_URL}"
        exit 1
    fi
}

install_binary() {
    log_info "Provisioning binary to ${BIN_DEST}..."
    mv "${TMP_DOWNLOAD}" "${BIN_DEST}"
    chmod 0755 "${BIN_DEST}"
    chown root:root "${BIN_DEST}"
}

main() {
    require_root
    download_script
    install_binary
    log_info "Installation complete. Run 'vmfc bootstrap' to initialize the environment."
}

main "$@"