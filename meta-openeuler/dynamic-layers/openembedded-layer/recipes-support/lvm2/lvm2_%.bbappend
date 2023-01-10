# main bbfile: meta-oe/recipes-support/lvm2/lvm2_2.03.11.bb?h=hardknott

require lvm2-src.inc

# remove strong dependence on udev, use condition statements to decide whether to depend udev
# keep the same as before
# use PACKAGECONFIG instead of LVM2_PACKAGECONFIG
LVM2_PACKAGECONFIG_remove_class-target = " \
    udev \
"
PACKAGECONFIG_append_class-target = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'udev', '', d)} \
"
