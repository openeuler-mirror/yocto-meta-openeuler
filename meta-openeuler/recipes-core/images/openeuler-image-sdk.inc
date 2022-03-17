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
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"

# host nativesdk packages added to sdk
TOOLCHAIN_HOST_TASK = " \
meta-environment-${MACHINE} \
gcc-bin-toolchain-cross-canadian-${TRANSLATED_TARGET_ARCH} \
"

# extra target packages added to sdk
TOOLCHAIN_TARGET_TASK += " \
kernel-devsrc \
"
