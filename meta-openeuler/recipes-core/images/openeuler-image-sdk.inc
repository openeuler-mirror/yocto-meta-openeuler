# set IMAGE_LOCALES_ARCHIVE to 0 and unset SDKIMAGE_LINGUAS, to avoid run generate_locale_archive()
IMAGE_LOCALES_ARCHIVE = "0"


# currently we don't install language configurations
SDKIMAGE_LINGUAS = ""
SDK_RELOCATE_AFTER_INSTALL = "${@['1', '0']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"
export SDK_OS = "linux"
# when PREBUILT_TOOLCHAIN_ENABLE is yes
# no need generate host packages, we directly use them in docker env, default in populate_sdk_base.bbclass
# when PREBUILT_TOOLCHAIN_ENABLE is no, most native/nativesdk packages can be built
# so we can follow poky's original way to handle sdk
TOOLCHAIN_HOST_TASK:remove = "${@["", 'nativesdk-packagegroup-sdk-host']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"
# use prebuilt tools build
SDK_DEPENDS:remove = "${@['', '${SDK_ARCHIVE_DEPENDS} cross-localedef-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

# do not need nativesdk-glibc-locale in external toolchain build
SDK_DEPENDS:remove:tcmode-external = "nativesdk-glibc-locale"

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

# the external toolchain in container may be read-only because of container configuration,
# so we need to make it writable here to guarantee the SDK after installation is writeable

# note: The reason we specify the full path to `chmod` here is because in some images, building
# the SDK can lead to a situation where it depends on `native-chmod`, and the native version
# tends to be relatively high which results in execution failures. Our goal is simply to grant
# write permissions to files under `sysroots`, so as a compromise solution, we specify `chmod`.
    /usr/bin/chmod -R u+w  ${SDK_OUTPUT}/${SDKPATH}/sysroots
}

# note: In RISC-V64, the lib directory points to the lib directory, even for 64-bit architectures.
# Therefore, it is necessary to copy the lib directory of the external toolchain into the SDK as well.
add_riscv64_lib_to_sdk () {
    cp -r ${EXTERNAL_TOOLCHAIN}/lib ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/
}

# functions added to last after sdk has been created
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"
# functions prepend to the front before sdk has been packaged
SDK_POSTPROCESS_COMMAND =+ "delete_bin_from_sdk; add_sysroot_link; add_include_link;"

SDK_POSTPROCESS_COMMAND:prepend:riscv64 = " add_riscv64_lib_to_sdk;"

# extra target packages added to sdk
# libgcc(libgcc_s.so) is required for user space application
TOOLCHAIN_TARGET_TASK += " \
libgcc \
kernel-devsrc \
${TCMODE-LIBC}-staticdev \
libstdc++-dev \
"

# static lib need for sdk toolchian
SDKIMAGE_FEATURES:append = " staticdev-pkgs dev-pkgs src-pkgs dbg-pkgs "
