SUMMARY = "linux kernel modules"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS_${PN} = " \
kernel-module-overlay \
kernel-module-8021q \
kernel-module-jbd2 \
kernel-module-mbcache \
kernel-module-ext2 \
kernel-module-ext4 \
kernel-module-inet-diag \
kernel-module-ip-tables \
kernel-module-ip-tunnel \
kernel-module-ip6-tables \
kernel-module-ip6-udp-tunnel \
kernel-module-ip6table-filter \
kernel-module-ipip \
kernel-module-ipt-reject \
kernel-module-iptable-filter \
kernel-module-ipv6 \
kernel-module-nf-conntrack \
kernel-module-nf-defrag-ipv4 \
kernel-module-nf-defrag-ipv6 \
kernel-module-nf-nat \
kernel-module-nf-reject-ipv4 \
kernel-module-nf-reject-ipv6 \
kernel-module-x-tables \
kernel-module-xt-tcpudp \
kernel-module-tunnel4 \
kernel-module-af-packet \
"
RDEPENDS_${PN}_raspberrypi4 = " \
"
RDEPENDS_${PN}_aarch64-pro = " \
"
