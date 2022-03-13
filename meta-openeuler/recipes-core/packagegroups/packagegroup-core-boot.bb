SUMMARY = "A small image just capable of allowing a device to boot."
LICENSE = "MIT"
PR = "r1"

inherit packagegroup

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
