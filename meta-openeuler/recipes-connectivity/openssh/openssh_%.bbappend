# main bb ref:
# yocto-poky/meta/recipes-connectivity/openssh/openssh_8.9p1.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "9.3p1"

# notice files in openssh are all from higher version of oe
# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-connectivity/openssh/openssh?id=c80a3a7a4a9dc40cbb675777a1ba1481532ecb05
FILESEXTRAPATHS:prepend := "${THISDIR}/openeuler-config/:"

# conflict: other openeuler patches can't apply
SRC_URI:prepend = " \
        file://openssh-${PV}.tar.gz \
        file://openssh-9.3p1-merged-openssl-evp.patch \
        file://bugfix-sftp-when-parse_user_host_path-empty-path-should-be-allowed.patch \
        file://add-loongarch.patch \
        file://openssh-Add-sw64-architecture.patch \
        file://skip-scp-test-if-there-is-no-scp-on-remote-path-as-s.patch \
        "

SRC_URI:remove = " \
        file://f107467179428a0e3ea9e4aa9738ac12ff02822d.patch \
        file://0001-Default-to-not-using-sandbox-when-cross-compiling.patch \
"

# in version 9.3p1, the line RDEPENDS:${PN}-dev = "" is removed
# Thus, ${PN}-dev has a default dependency on ${PN}
RDEPENDS:${PN}-dev = "${PN}"

LIC_FILES_CHKSUM = "file://LICENCE;md5=072979064e691d342002f43cd89c0394"
SRC_URI[sha256sum] = "200ebe147f6cb3f101fd0cdf9e02442af7ddca298dffd9f456878e7ccac676e8"

# 9.3p1 version of bb file adds this configuration
RDEPENDS:${PN}-ptest += "openssl-bin"