# Central lopper-ops bbappend.
#
# Machine-specific lopper configurations are in <MACHINE>.inc files.
# During build, MACHINE equals the target platform name (e.g.
# "qemu-aarch64" or "raspberrypi4-64"), so "include ${MACHINE}.inc"
# picks up the right configuration for the current platform.
#
# - qemu-aarch64.inc and lops/lop-extract-rtc-for-guest.dts live in
#   this directory (meta-openeuler layer).
# - raspberrypi4-64.inc and lops/lop-extract-uart5-for-zephyr.dts live
#   in the raspberrypi BSP layer (bsp/meta-openeuler-bsp/raspberrypi/
#   recipes-kernel/lopper/), found via its own lopper-ops.bbappend
#   FILESEXTRAPATHS.

FILESEXTRAPATHS:prepend := "${THISDIR}/:"

include ${MACHINE}.inc
