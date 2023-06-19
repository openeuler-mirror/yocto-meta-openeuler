require openeuler-xorg-lib-common.inc

OPENEULER_REPO_NAME = "xorg-x11-xtrans-devel"

XORG_EXT = "tar.bz2"

PV = "1.4.0"

# openeuler patches
SRC_URI:prepend = "file://xtrans-1.0.3-avoid-gethostname.patch \
           file://backport-0001-Automatically-disable-inet6-transport-if-ipv6-is-dis.patch \
           "
