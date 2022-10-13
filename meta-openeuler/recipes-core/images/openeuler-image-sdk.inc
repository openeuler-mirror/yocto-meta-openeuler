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
    for d in ./bin ./usr/bin/ ./usr/sbin/ ./sbin/
    do
        test -d "$d" && rm -r "$d"
    done
    popd
}

add_sysroot_link() {
    # users may use aarch64-openeuler-linux-gcc to compile files without --sysroot
    # add sysroot link to the real sysroot dir for using convenient.
    pushd ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/${EXTERNAL_TARGET_SYS}/
    # must relative path, otherwise will not found after decompression.
    ln -s ../../../${REAL_MULTIMACH_TARGET_SYS} sysroot
    popd
}

add_include_link() {
    # users may use aarch64-openeuler-linux-g++ to compile files without --include
    # add include link to the real usr/include dir for using convenient.
    pushd ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/${EXTERNAL_TARGET_SYS}
    # must relative path, otherwise will not found after decompression
    ln -s ../../../${REAL_MULTIMACH_TARGET_SYS}/usr/include include
    popd
}

#functions added to last after sdk has been created
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"
#functions prepend to the front before sdk has been packaged
SDK_POSTPROCESS_COMMAND =+ "delete_bin_from_sdk; add_sysroot_link; add_include_link;"

# host nativesdk packages added to sdk
TOOLCHAIN_HOST_TASK = " \
meta-environment-${MACHINE} \
gcc-external-cross-canadian-${TRANSLATED_TARGET_ARCH} \
"


# extra target packages added to sdk
# libgcc(libgcc_s.so) is required for user space application
TOOLCHAIN_TARGET_TASK += " \
libgcc \
kernel-devsrc \
glibc-external-staticdev \
libstdc++-dev \
"
