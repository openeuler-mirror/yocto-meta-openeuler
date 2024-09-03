PV = "2.72"

SRC_URI:prepend = "file://${BP}.tar.xz \
"

do_prepare_gnu_config() {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ];then
        test -d "${STAGING_DATADIR_NATIVE}/gnu-config/" || mkdir -p "${STAGING_DATADIR_NATIVE}/gnu-config/"
        rm -rf ${STAGING_DATADIR_NATIVE}/gnu-config/*
        install -m 0755 ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/gnu-config/config.guess  ${STAGING_DATADIR_NATIVE}/gnu-config/
        install -m 0755 ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/gnu-config/config.sub  ${STAGING_DATADIR_NATIVE}/gnu-config/
    fi
}

SRC_URI:remove = " \
    file://backport-_AC_PROG_CXX_STDCXX_EDITION_TRY-fix-typo-in-variable.patch \
    file://backport-Fix-testsuite-failures-with-bash-5.2.patch \
    file://skip-one-test-at-line-1616-of-autotest.patch \
    file://0001-Port-to-compilers-that-moan-about-K-R-func-decls.patch \
"

RDEPENDS:${PN} = " \
    perl-module-feature \
"

do_prepare_recipe_sysroot[postfuncs] += "do_prepare_gnu_config"
