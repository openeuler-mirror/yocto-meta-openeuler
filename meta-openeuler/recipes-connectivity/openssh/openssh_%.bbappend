# main bb ref:
# yocto-poky/meta/recipes-connectivity/openssh/openssh_8.9p1.bb

# version in openEuler
PV = "9.6p1"

# notice files in openssh are all from higher version of oe
# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-connectivity/openssh/openssh?id=c80a3a7a4a9dc40cbb675777a1ba1481532ecb05
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# conflict: other openeuler patches can't apply
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://openssh-9.3p1-merged-openssl-evp.patch \
        file://bugfix-sftp-when-parse_user_host_path-empty-path-should-be-allowed.patch \
        file://add-loongarch.patch \
        file://openssh-Add-sw64-architecture.patch \
        file://skip-scp-test-if-there-is-no-scp-on-remote-path-as-s.patch \
        file://backport-fix-CVE-2024-6387.patch \
        "

# backport-CVE-2023-48795 (strict key exchange) and CVE-2023-51385
# (ban user hostnames with shell metacharacters) are included in
# 9.6p1 upstream and the patches were dropped from the src repo

SRC_URI:remove = " \
        file://f107467179428a0e3ea9e4aa9738ac12ff02822d.patch \
        file://0001-Default-to-not-using-sandbox-when-cross-compiling.patch \
"

# in version 9.3p1, the line RDEPENDS:${PN}-dev = "" is removed
# Thus, ${PN}-dev has a default dependency on ${PN}
RDEPENDS:${PN}-dev = "${PN}"

LIC_FILES_CHKSUM = "file://LICENCE;md5=072979064e691d342002f43cd89c0394"
SRC_URI[sha256sum] = "910211c07255a8c5ad654391b40ee59800710dd8119dd5362de09385aa7a777c"

# 9.3p1 version of bb file adds this configuration
RDEPENDS:${PN}-ptest += "openssl-bin"

SRC_URI:append = " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' file://sshd.service ', '', d)} \
"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        # 当DISTRO_FEATURES包含systemd时执行以下操作
        install -d ${D}${systemd_system_unitdir}
        install -c -m 0644 ${WORKDIR}/sshd.service ${D}${systemd_system_unitdir}/
    fi
}

# 确保文件被打包
FILES:${PN}-sshd += "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' ${systemd_system_unitdir}/sshd.service ', '', d)}"

SYSTEMD_SERVICE:${PN}-sshd = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' sshd.service ', ' sshd.socket ', d)}"

ASSUME_PROVIDE_PKGS = "openssh"
