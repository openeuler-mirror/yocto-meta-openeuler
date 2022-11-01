require selinux_common.inc
require ${BPN}.inc

LIC_FILES_CHKSUM = "file://LICENSE;md5=84b4d2c6ef954a2d4081e775a270d0d0"

SRC_URI = "file://libselinux/libselinux-${PV}.tar.gz \
        file://backport-libselinux-Close-leaked-FILEs.patch \
        file://backport-libselinux-free-memory-on-selabel_open-3-failure.patch \
        file://backport-libselinux-restorecon-misc-tweaks.patch \
        file://backport-libselinux-free-memory-in-error-branch.patch \
        file://backport-libselinux-restorecon-avoid-printing-NULL-pointer.patch \
        file://libselinux/do-malloc-trim-after-load-policy.patch \
"
