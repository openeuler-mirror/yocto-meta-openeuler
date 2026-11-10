# the RPi kernel tree (kernel-${PV}-tag-rpi) is pinned to its own tag,
# so the RPi kernel patch must come from the matching src-openeuler
# packaging tag (src-kernel-${PV}-tag-rpi) instead of src-kernel-${PV},
# which follows the mainline kernel6 packaging rebased per baseline
# the 5.10 bcm2711_defconfig created by the packaging patch still requests
# the tcindex/rsvp classifiers, which the openEuler 5.10 kernel removed;
# drop them (right after the packaging patch) so do_kernel_configcheck
# does not report missing symbols. the 6.6 defconfig is already clean.
SRC_URI:append:raspberrypi4-64 = " \
    file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'file://0001-rpi-defconfig-drop-removed-cls-classifiers.patch', d)} \
"
# since the 6.6.0-174.0.0 packaging the tag-rpi tree moves to the same
# kernel tag as the mainline kernel-6.6 baseline, so the mainline zImage
# patch (refreshed for 174.0.0) applies and no tag-matching variant is
# needed anymore
require linux-openeuler-rpi.inc
