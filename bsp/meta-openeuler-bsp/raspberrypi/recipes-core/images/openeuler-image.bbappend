FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
#fix mkfs.ext4 running error, add -E no_copy_xattrs to mkfs.ext4
WKS_FILE = "sdimage-rpi.wks"
WKS_FILE_DEPENDS = ""

require ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'mcs.inc', '', d)}
require ${@bb.utils.contains('BUILD_GUEST_OS', '1', 'initrd-install.inc', '', d)}
