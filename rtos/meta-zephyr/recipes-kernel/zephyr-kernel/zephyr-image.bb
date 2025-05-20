SUMMARY = "The Zephyr OS image"
DESCRIPTION = "This recipe is a bridge to build zephyr image in openEuler Embedded"

# currently compatible machines
COMPATIBLE_MACHINE = "qemu-aarch64|raspberrypi4-64|kp920"

# common part to build zephyr image
include zephyr-image.inc

PV = "${ZEPHYR_VERSION}"

# the default zephyr application
ZEPHYR_APP_DIR ?= "${ZEPHYR_BASE}/samples/subsys/shell/devmem_load"

python () {
    machine = d.getVar('MACHINE').split()
    mcs_features = d.getVar('MCS_FEATURES').split()
    distro_features = d.getVar('DISTRO_FEATURES').split()

    # qemu-aarch64 related handling
    if 'qemu-aarch64' in machine:
        if 'openamp' in mcs_features:
            d.setVar('ZEPHYR_BOARD', 'qemu_cortex_a53/qemu_cortex_a53/remote')
        elif 'jailhouse' in mcs_features:
            d.setVar('ZEPHYR_BOARD', 'qemu_cortex_a53/qemu_cortex_a53/ivshmem')
    elif 'raspberrypi4-64' in machine:
        if 'openamp' in mcs_features:
            d.setVar('ZEPHYR_BOARD', 'rpi_4b/rpi_4b/remote')
        elif 'jailhouse' in mcs_features:
            d.setVar('ZEPHYR_BOARD', 'rpi_4b/rpi_4b/ivshmem')
    elif 'kp920' in machine:
        if 'xen' in distro_features:
            d.setVar('ZEPHYR_BOARD', 'xenvm/xenvm/gicv3')
            d.setVar('ZEPHYR_APP_DIR', "${ZEPHYR_BASE}/samples/synchronization")

}
