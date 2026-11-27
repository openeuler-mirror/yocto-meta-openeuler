# the rpi kernel patches come from the src-kernel-${PV}-tag-rpi lineage
# for both the 5.10 and the kernel6 baselines
SRC_URI:append:raspberrypi4 = " \
    file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
"
require linux-openeuler-rpi.inc
