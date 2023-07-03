SUMMARY = "The Zephyr OS image"
DESCRIPTION = "This recipe is a bridge to build zephyr image in openEuler Embedded"

OPENEULER_FETCH = "disable"

# currently compatible machines
COMPATIBLE_MACHINE = "qemu-aarch64|raspberrypi4-64"

# the target zephyr board, currently two boards supported in openEuler Embedded
#  - qemu_cortex_a53, which matches qemu-aarch64 of openEuler Embedded
#  - rpi_cortex_a72, which matches raspberry pi 4 B of openEuler Embedded
ZEPHYR_BOARD:qemu-aarch64 = "qemu_cortex_a53_remote"
ZEPHYR_BOARD:raspberrypi4-64 = "rpi4_cortex_a72"

# common part to build zephyr image
include zephyr-image.inc

PV = "${ZEPHYR_VERSION}"

# the default zephyr application
ZEPHYR_SRC_DIR ?= "${ZEPHYR_BASE}/samples/subsys/shell/devmem_load"
