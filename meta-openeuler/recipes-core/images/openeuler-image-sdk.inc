inherit populate_sdk
#set IMAGE_LOCALES_ARCHIVE to 0 and unset SDKIMAGE_LINGUAS, to avoid run generate_locale_archive()
IMAGE_LOCALES_ARCHIVE = "0"
# currently we don't install language configurations
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
    popd
}

#funcs added to last after sdk has been created
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"
#funcs prepend to the front before sdk has been packaged
SDK_POSTPROCESS_COMMAND =+ "delete_bin_from_sdk;"

# host nativesdk packages added to sdk
TOOLCHAIN_HOST_TASK = " \
meta-environment-${MACHINE} \
gcc-external-cross-canadian-${TRANSLATED_TARGET_ARCH} \
"


# extra target packages added to sdk
TOOLCHAIN_TARGET_TASK += " \
kernel-devsrc \
"
