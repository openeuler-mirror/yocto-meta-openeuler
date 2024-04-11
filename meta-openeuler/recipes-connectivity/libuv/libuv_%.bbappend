# main bb file: yocto-poky/meta/recipes-connectivity/libuv/libuv_1.44.2.bb

# version in openEuler
PV = "1.47.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=74b6f2f7818a4e3a80d03556f71b129b"

# apply openEuler source package
SRC_URI:prepend = "file://${BPN}-v${PV}.tar.gz \
        file://0001-unix-ignore-ifaddrs-with-NULL-ifa_addr-4218.patch \
        file://0002-test-check-if-ipv6-link-local-traffic-is-routable.patch \
        file://0003-test_fs.c-Fix-issue-on-32-bit-systems-using-btrfs.patch \
        file://backport-0001-CVE-2024-24806.patch \
        file://backport-0002-CVE-2024-24806.patch \
        file://backport-0003-CVE-2024-24806.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"
