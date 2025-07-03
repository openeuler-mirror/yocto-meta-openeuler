
do_compile:append() {
    if [[ "${VIRTUAL-RUNTIME_dev_manager}" = "busybox-mdev" || -z "${VIRTUAL-RUNTIME_dev_manager}" ]]; then
        bbwarn "${PN} depends udev. \
Current device manager: '${VIRTUAL-RUNTIME_dev_manager}'. \
To resolve this issue, either: \
1. Configure udev or systemd-udev as your device manager, or \
2. Remove DISTRO_FEATURES that depend on ${PN} (e.g., 3g, phone)."
    fi
}