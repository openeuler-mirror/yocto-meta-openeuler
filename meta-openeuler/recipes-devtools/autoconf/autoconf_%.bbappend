
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

do_prepare_recipe_sysroot[postfuncs] += "do_prepare_gnu_config"
