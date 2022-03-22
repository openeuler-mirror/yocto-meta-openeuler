inherit populate_sdk
#set IMAGE_LOCALES_ARCHIVE to 0 and unset SDKIMAGE_LINGUAS, to avoid run generate_locale_archive()
IMAGE_LOCALES_ARCHIVE = "0"
SDKIMAGE_LINGUAS = ""
SDK_RELOCATE_AFTER_INSTALL = "0"

export SDK_OS = "linux"

SDK_DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])}"

copy_opeueuler_sdk() {
   test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
   cp -fp ${SDKDEPLOYDIR}/${TOOLCHAIN_OUTPUTNAME}.sh "${OUTPUT_DIR}"/
}

delete_bin_from_sdk() {
    #delete binary from sdk to ignore command function error, we need command at host
    pushd ${SDK_OUTPUT}/${SDKTARGETSYSROOT}/
    rm -f ./usr/bin/*
    rm -f ./usr/sbin/*
    rm -f ./sbin/*
    pushd ./bin/
    #only reserve compiler command
    cc="$(echo "${CC}" | awk '{print $1}')"
    cc_prefix="${cc%-*}"
    real_cc_prefix="xxxxx"
    if [ -L "${cc}" ];then
        real_cc="$(ls -l "${cc}" | awk '{print $NF}')"
        real_cc_prefix="${real_cc%-*}"
    fi
    rm -f $(ls | grep -Ev "${cc_prefix}|${real_cc_prefix}")
    popd
    popd
}

#funcs added to last after sdk has been created
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"
#funcs prepend to the front before sdk has been packaged
SDK_POSTPROCESS_COMMAND =+ "delete_bin_from_sdk;"

# host nativesdk packages added to sdk
TOOLCHAIN_HOST_TASK = " \
meta-environment-${MACHINE} \
gcc-bin-toolchain-cross-canadian-${TRANSLATED_TARGET_ARCH} \
"

# extra target packages added to sdk
TOOLCHAIN_TARGET_TASK += " \
kernel-devsrc \
"
