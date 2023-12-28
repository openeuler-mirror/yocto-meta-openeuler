# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_8.32.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "9.3"

# solve lic check failed
LIC_FILES_CHKSUM:remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=b720a8b317035d66c555fc6d89e3674c \
"

# files, patches can't be applied in openeuler or conflict with openeuler
# remove-usr-local-lib-from-m4.patch same as bugfix-remove-usr-local-lib-from-m4.patch
SRC_URI:remove = " \
        file://remove-usr-local-lib-from-m4.patch \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://e8b56ebd536e82b15542a00c888109471936bfda.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0001-disable-test-of-rwlock.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://coreutils-getgrouplist.patch \
        file://bugfix-remove-usr-local-lib-from-m4.patch \
        file://bugfix-dummy_help2man.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch \
        file://backport-config-color-alias-for-ls.patch \
        file://backport-coreutils-i18n.patch \
        file://backport-pr-fix-infinite-loop-when-double-spacing.patch \
"  

# patch from coreutils-9.3
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"
SRC_URI:append = " \
           file://stdlib-mb-cur-max.patch \
           "

SRC_URI[sha256sum] = "ce30acdf4a41bc5bb30dd955e9eaa75fa216b4e3deb08889ed32433c7b3b97ce"
