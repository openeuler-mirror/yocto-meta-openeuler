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
    cd ${SDK_OUTPUT}/${SDKTARGETSYSROOT}/
    whitelist="./usr/bin/fast-discovery-server-1.0.0 ./usr/bin/nodesize_dbg"
    backup_dir="./backup_tmp_bin"
    mkdir -p $backup_dir
    for file in $whitelist
    do
        if [ -e "$file" ]; then
            cp -pr "$file" "$backup_dir/$(basename "$file")_$(dirname "$file" | tr / _)" || true
        fi
    done
    for d in ./bin ./usr/bin/ ./usr/sbin/ ./sbin/
    do
        test -d "$d" && rm -r "$d"
    done
    for file in $whitelist
    do
        backup_file="$backup_dir/$(basename "$file")_$(dirname "$file" | tr / _)"
        if [ -e "$backup_file" ]; then
            mkdir -p "$(dirname "$file")"
            cp -pr "$backup_file" "$file" || true
        fi
    done
    rm -rf $backup_dir || true
    cd -
}

add_sysroot_link() {
    # users may use aarch64-openeuler-linux-gcc to compile files without --sysroot
    # add sysroot link to the real sysroot dir for using convenient.
    cd ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/${EXTERNAL_TARGET_SYS}/
    # must relative path, otherwise will not found after decompression.
    ln -s ../../../${REAL_MULTIMACH_TARGET_SYS} sysroot
    cd -
}

add_include_link() {
    # users may use aarch64-openeuler-linux-g++ to compile files without --include
    # add include link to the real usr/inlucde dir for using convenient.
    cd ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/${EXTERNAL_TARGET_SYS}/
    # must relative path, otherwise will not found after decompression.
    ln -s ../../../${REAL_MULTIMACH_TARGET_SYS}/usr/include include
    cd -
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
${TCMODE-LIBC}-staticdev \
libstdc++-dev \
"

# add openamp dev to sdk
TOOLCHAIN_TARGET_TASK += " \
openamp-dev \
libmetal-dev \
sysfsutils-dev \
"
