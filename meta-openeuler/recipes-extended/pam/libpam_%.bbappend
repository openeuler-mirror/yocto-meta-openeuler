PV = "1.5.2"

# get files from pam, not libpam
OPENEULER_REPO_NAME = "pam"

# delete useless patch from old version in poky bb
SRC_URI_remove += " \
    file://0001-modules-pam_namespace-Makefile.am-correctly-install-.patch \
    file://0001-Makefile.am-support-usrmage.patch \
"

# patch from openeuler
SRC_URI += " \
           file://pam/bugfix-pam-1.1.8-faillock-systemtime.patch \
           file://pam/openEuler-change-ndbm-to-gdbm.patch \
           file://pam/0001-bugfix-cannot-open-database-file.patch \
           file://pam/add-sm3-crypt-support.patch \
"
SRC_URI[sha256sum] = "e4ec7131a91da44512574268f493c6d8ca105c87091691b8e9b56ca685d4f94d"

DEPENDS_remove += "flex"

# no coreutils in openeuler
RDEPENDS_${PN}-xtests_remove += " \
    coreutils \
"

PACKAGES += "${PN}-pkgconfig ${PN}-service"
FILES_${PN}-pkgconfig = "${base_libdir}/pkgconfig"
FILES_${PN}-service = "/usr/lib/systemd/system"
