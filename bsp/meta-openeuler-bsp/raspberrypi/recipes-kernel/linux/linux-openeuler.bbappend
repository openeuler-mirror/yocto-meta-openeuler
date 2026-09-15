# the RPi kernel tree (kernel-${PV}-tag-rpi) is pinned to its own tag,
# so the RPi kernel patch must come from the matching src-openeuler
# packaging tag (src-kernel-${PV}-tag-rpi) instead of src-kernel-${PV},
# which follows the mainline kernel6 packaging rebased per baseline
SRC_URI:append:raspberrypi4-64 = " \
    file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
"
require linux-openeuler-rpi.inc
