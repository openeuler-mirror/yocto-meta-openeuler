# main bb: yocto-poky/meta/recipes-core/glibc/cross-localedef-native_2.33.bb
#
OPENEULER_REPO_NAME = "glibc"
OPENEULER_LOCAL_NAME = "glibc"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_prepend = " \
    file://glibc-${PV}.tar.xz \
    file://localedef-master-e0eca29.zip \
"

SRC_URI_remove = " \
    ${GLIBC_GIT_URI};branch=${SRCBRANCH};name=glibc \
    git://github.com/kraj/localedef;branch=master;name=localedef;destsuffix=git/localedef;protocol=https \
"

S = "${WORKDIR}/glibc-${PV}"

do_unpack_append() {
    bb.build.exec_func('do_copy_localedef_source', d)
}

do_copy_localedef_source() {
    mv ${WORKDIR}/localedef-master ${S}/localedef
}

