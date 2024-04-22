# add wifi related packages
RDEPENDS:packagegroup-base:append = " \
${@bb.utils.contains('AUTOEXPAND', '1', 'parted util-linux-findmnt e2fsprogs-resize2fs', '', d)} \
"
