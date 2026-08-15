# QEMU virt platform lopper configuration.
#
# Extracts the PL031 RTC (pl031@9010000) from the QEMU virt device tree
# for the guest OS, and removes it from the Linux device tree so Linux
# no longer sees the RTC device.
#
# Verification at runtime:
#   - Standard image:  /sys/class/rtc/ contains rtc0
#   - MCS+lopper image: /sys/class/rtc/ is empty (RTC partitioned to guest)
#
# The lop file is installed to LOPS_DIR by lopper-ops.bb and applied by
# lopper-devicetree.bbclass when a recipe inherits it.

SRC_URI:append:qemu-aarch64 = " file://lops/lop-extract-rtc-for-guest.dts"
