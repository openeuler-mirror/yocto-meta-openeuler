# Raspberry Pi 4 platform lopper configuration.
#
# Extracts UART5 (serial@7e201a00) from the RPi4 device tree for Zephyr,
# and removes it from the Linux device tree so Linux no longer sees UART5.
#
# Verification at runtime:
#   - Standard image:  /proc/tty/driver/* shows 3 uarts
#   - MCS+lopper image: /proc/tty/driver/* shows 2 uarts (UART5 partitioned)
#
# The lop file is installed to LOPS_DIR by lopper-ops.bb and applied by
# lopper-devicetree.bbclass when rpi-bootfiles.bbappend inherits it
# (conditional on MCS_FEATURES containing "lopper-devicetree").

SRC_URI:append:raspberrypi4-64 = " file://lops/lop-extract-uart5-for-zephyr.dts"
