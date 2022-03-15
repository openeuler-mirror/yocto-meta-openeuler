inherit populate_sdk
#set IMAGE_LOCALES_ARCHIVE to 0 and unset SDKIMAGE_LINGUAS, to avoid run generate_locale_archive()
IMAGE_LOCALES_ARCHIVE = "0"
SDKIMAGE_LINGUAS = ""
SDK_RELOCATE_AFTER_INSTALL = "0"

inherit populate_sdk_ext
export SDK_OS = "linux"
TOOLCHAIN_HOST_TASK_task-populate-sdk-ext = ""

SDK_DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])}"

copy_opeueuler_sdk() {
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
