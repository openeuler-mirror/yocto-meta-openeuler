SUMMARY = "A small image just capable of allowing a device to boot."
LICENSE = "MIT"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN} ${PN}-tiny"

RDEPENDS_${PN} = " \
busybox-linuxrc \
kernel \
kernel-img \
kernel-vmlinux \
busybox \
os-base \
glibc \
os-release \
"

RDEPENDS_${PN}-tiny = " \
busybox-login \
busybox-groups \
busybox-bash \
busybox-grep \
busybox-sed \
"
