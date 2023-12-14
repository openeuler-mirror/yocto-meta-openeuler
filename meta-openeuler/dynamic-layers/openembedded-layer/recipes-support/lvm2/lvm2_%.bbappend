# main bbfile: meta-oe/recipes-support/lvm2/lvm2_2.03.11.bb?h=hardknott

require lvm2-src.inc

# remove strong dependence on udev, use condition statements to decide whether to depend udev
# keep the same as before
# use PACKAGECONFIG instead of LVM2_PACKAGECONFIG
LVM2_PACKAGECONFIG:remove:class-target = " \
    udev \
"
PACKAGECONFIG:append:class-target = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'udev', '', d)} \
"

# from poky lvm2_2.03.16.bb
RDEPENDS:${PN} = "bash"
