# main bb: yocto-poky/meta/recipes-core/glibc/cross-localedef-native_2.35.bb
#
OPENEULER_REPO_NAME = "glibc"
OPENEULER_LOCAL_NAME = "glibc"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = " \
    file://glibc-2.38.tar.xz \
    file://localedef-master-e0eca29.zip \
"

S = "${WORKDIR}/glibc-2.38"

do_unpack:append() {
    bb.build.exec_func('do_copy_localedef_source', d)
}

do_copy_localedef_source() {
    mv ${WORKDIR}/localedef-master ${S}/localedef
}

