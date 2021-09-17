SUMMARY = "Dummy Linux kernel"
DESCRIPTION = "Dummy Linux kernel, to be selected as the preferred \
provider for virtual/kernel to satisfy dependencies for situations \
where you wish to build the kernel externally from the build system."
SECTION = "kernel"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

PROVIDES += "virtual/kernel"

#inherit deploy linux-dummy
inherit kernel-arch
inherit kernel-version kernel-module-split
export EXTRA_CFLAGS = "${CFLAGS}"
export EXTRA_LDFLAGS = "${LDFLAGS}"

EXTRA_OEMAKE = "CC='${CC}' LD='${CCLD}' V=1 ARCH=${ARCH} CROSS_COMPILE=${TARGET_PREFIX} SKIP_STRIP=y HOSTCC='${BUILD_CC}' HOSTCPP='${BUILD_CPP}'"
EXTRA_OEMAKE = "CC='${CC}' V=1 ARCH=${ARCH} CROSS_COMPILE=${TARGET_PREFIX} SKIP_STRIP=y HOSTCC='${BUILD_CC}' HOSTCPP='${BUILD_CPP}'"

PACKAGES_DYNAMIC += "^kernel-module-.*"
PACKAGES_DYNAMIC += "^kernel-image-.*"
PACKAGES_DYNAMIC += "^kernel-firmware-.*"

KERNEL_CLASSES ?= " kernel-uimage "
inherit ${KERNEL_CLASSES}

KERNEL_VERSION = "${@get_kernelversion_headers('${B}')}"
KERNEL_IMAGETYPE_FOR_MAKE = "zImage"
KERNEL_PACKAGE_NAME ??= "kernel"
KERNEL_IMAGETYPE ?= "zImage"
# kernel-base becomes kernel-${KERNEL_VERSION}
# kernel-image becomes kernel-image-${KERNEL_VERSION}
PACKAGES = "${PN} ${KERNEL_PACKAGE_NAME} ${KERNEL_PACKAGE_NAME}-base ${KERNEL_PACKAGE_NAME}-vmlinux ${KERNEL_PACKAGE_NAME}-image ${KERNEL_PACKAGE_NAME}-dev ${KERNEL_PACKAGE_NAME}-modules"
FILES_${PN} = ""
FILES_${KERNEL_PACKAGE_NAME}-base = "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/modules.order ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/modules.builtin ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/modules.builtin.modinfo"
FILES_${KERNEL_PACKAGE_NAME}-image = "/boot/${KERNEL_IMAGETYPE}-${KERNEL_VERSION} /boot/vmlinux-${KERNEL_VERSION}"
FILES_${KERNEL_PACKAGE_NAME}-dev = "/boot/System.map* /boot/Module.symvers* /boot/config* ${KERNEL_SRC_PATH} ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/build"
FILES_${KERNEL_PACKAGE_NAME}-vmlinux = "/boot/vmlinux-${KERNEL_VERSION_NAME}"
FILES_${KERNEL_PACKAGE_NAME}-modules = ""
RDEPENDS_${KERNEL_PACKAGE_NAME} = "${KERNEL_PACKAGE_NAME}-base (= ${EXTENDPKGV})"
# Allow machines to override this dependency if kernel image files are
# not wanted in images as standard
RDEPENDS_${KERNEL_PACKAGE_NAME}-base ?= "${KERNEL_PACKAGE_NAME}-image (= ${EXTENDPKGV})"
PKG_${KERNEL_PACKAGE_NAME}-image = "${KERNEL_PACKAGE_NAME}-image-${@legitimize_package_name(d.getVar('KERNEL_VERSION'))}"
RDEPENDS_${KERNEL_PACKAGE_NAME}-image += "${@oe.utils.conditional('KERNEL_IMAGETYPE', 'vmlinux', '${KERNEL_PACKAGE_NAME}-vmlinux (= ${EXTENDPKGV})', '', d)}"
PKG_${KERNEL_PACKAGE_NAME}-base = "${KERNEL_PACKAGE_NAME}-${@legitimize_package_name(d.getVar('KERNEL_VERSION'))}"
RPROVIDES_${KERNEL_PACKAGE_NAME}-base += "${KERNEL_PACKAGE_NAME}-${KERNEL_VERSION}"
ALLOW_EMPTY_${KERNEL_PACKAGE_NAME} = "1"
ALLOW_EMPTY_${KERNEL_PACKAGE_NAME}-base = "1"
ALLOW_EMPTY_${KERNEL_PACKAGE_NAME}-image = "1"
ALLOW_EMPTY_${KERNEL_PACKAGE_NAME}-modules = "1"
DESCRIPTION_${KERNEL_PACKAGE_NAME}-modules = "Kernel modules meta package"

#PACKAGESPLITFUNCS_prepend = "split_kernel_packages "
inherit kernel-artifact-names
inherit kernel-devicetree
#INHIBIT_DEFAULT_DEPS = "1"

COMPATIBLE_HOST = ".*-linux"

PR = "r1"

SRC_URI = "file://kernel-5.10 \
           file://yocto-embedded-tools/config/arm64/defconfig-kernel \
           file://yocto-embedded-tools/patches/arm64/0001-arm64-add-zImage-support-for-arm64.patch \
          "
S = "${WORKDIR}/kernel-5.10"
B = "${WORKDIR}/build"

KERNEL_CONFIG_COMMAND ?= "oe_runmake_call -C ${S} CC="${KERNEL_CC}" LD="${KERNEL_LD}" O=${B} olddefconfig || oe_runmake -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" oldnoconfig"
KCONFIG_CONFIG_COMMAND_append = " LD='${KERNEL_LD}' HOSTLDFLAGS='${BUILD_LDFLAGS}'"

KERNEL_RELEASE ?= "${KERNEL_VERSION}"
# The directory where built kernel lies in the kernel tree
KERNEL_OUTPUT_DIR ?= "arch/${ARCH}/boot"
KERNEL_IMAGEDEST ?= "boot"

python do_symlink_kernsrc () {
    s = d.getVar("S")
    if s[-1] == '/':
        # drop trailing slash, so that os.symlink(kernsrc, s) doesn't use s as directory name and fail
        s=s[:-1]
    kernsrc = d.getVar("STAGING_KERNEL_DIR")
    if s != kernsrc:
        bb.utils.mkdirhier(kernsrc)
        bb.utils.remove(kernsrc, recurse=True)
        if d.getVar("EXTERNALSRC"):
            # With EXTERNALSRC S will not be wiped so we can symlink to it
            os.symlink(s, kernsrc)
        else:
            import shutil
            shutil.move(s, kernsrc)
            os.symlink(kernsrc, s)
}
addtask symlink_kernsrc before do_patch do_configure after do_unpack

do_configure() {
        cp ../yocto-embedded-tools/config/arm64/defconfig-kernel .config
        set -e
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        oe_runmake -C ${S} ARCH=arm64 mrproper
        ${KERNEL_CONFIG_COMMAND}
        #yes '' | oe_runmake oldconfig
        oe_runmake -C ${B} savedefconfig
}

get_cc_option () {
                # Check if KERNEL_CC supports the option "file-prefix-map".
                # This option allows us to build images with __FILE__ values that do not
                # contain the host build path.
                if ${KERNEL_CC} -Q --help=joined | grep -q "\-ffile-prefix-map=<old=new>"; then
                        echo "-ffile-prefix-map=${S}=/kernel-source/"
                fi
}

do_compile () {
        cc_extra=$(get_cc_option)
        oe_runmake CC="${KERNEL_CC} $cc_extra " LD="${KERNEL_LD}" ${KERNEL_EXTRA_ARGS}
}

do_compile_kernelmodules() {
    :
}

do_shared_workdir () {
	:
}

do_install() {
        #
        # First install the modules
        #
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE
        if (grep -q -i -e '^CONFIG_MODULES=y$' .config); then
                oe_runmake DEPMOD=echo MODLIB=${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION} INSTALL_FW_PATH=${D}${nonarch_base_libdir}/firmware modules_install
                rm "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/build"
                rm "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/source"
                # If the kernel/ directory is empty remove it to prevent QA issues
                rmdir --ignore-fail-on-non-empty "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel"
        else
                bbnote "no modules to install"
        fi

        #
        # Install various kernel output (zImage, map file, config, module support files)
        #
        install -d ${D}/${KERNEL_IMAGEDEST}
        install -d ${D}/boot

        for imageType in ${KERNEL_IMAGETYPES} ; do
                if [ $imageType != "fitImage" ] || [ "${INITRAMFS_IMAGE_BUNDLE}" != "1" ] ; then
                        install -m 0644 ${KERNEL_OUTPUT_DIR}/$imageType ${D}/${KERNEL_IMAGEDEST}/$imageType-${KERNEL_VERSION}
                fi
        done

        install -m 0644 System.map ${D}/boot/System.map-${KERNEL_VERSION}
        install -m 0644 .config ${D}/boot/config-${KERNEL_VERSION}
        install -m 0644 vmlinux ${D}/boot/vmlinux-${KERNEL_VERSION}
        [ -e Module.symvers ] && install -m 0644 Module.symvers ${D}/boot/Module.symvers-${KERNEL_VERSION}
        install -d ${D}${sysconfdir}/modules-load.d
        install -d ${D}${sysconfdir}/modprobe.d
}

do_bundle_initramfs() {
        return 0
        if [ ! -z "${INITRAMFS_IMAGE}" -a x"${INITRAMFS_IMAGE_BUNDLE}" = x1 ]; then
                echo "Creating a kernel image with a bundled initramfs..."
                copy_initramfs
                # Backing up kernel image relies on its type(regular file or symbolic link)
                tmp_path=""
                for imageType in ${KERNEL_IMAGETYPE_FOR_MAKE} ; do
                        if [ -h ${KERNEL_OUTPUT_DIR}/$imageType ] ; then
                                linkpath=`readlink -n ${KERNEL_OUTPUT_DIR}/$imageType`
                                realpath=`readlink -fn ${KERNEL_OUTPUT_DIR}/$imageType`
                                mv -f $realpath $realpath.bak
                                tmp_path=$tmp_path" "$imageType"#"$linkpath"#"$realpath
                        elif [ -f ${KERNEL_OUTPUT_DIR}/$imageType ]; then
                                mv -f ${KERNEL_OUTPUT_DIR}/$imageType ${KERNEL_OUTPUT_DIR}/$imageType.bak
                                tmp_path=$tmp_path" "$imageType"##"
                        fi
                done
                use_alternate_initrd=CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE_NAME}.cpio
                kernel_do_compile
                # Restoring kernel image
                for tp in $tmp_path ; do
                        imageType=`echo $tp|cut -d "#" -f 1`
                        linkpath=`echo $tp|cut -d "#" -f 2`
                        realpath=`echo $tp|cut -d "#" -f 3`
                        if [ -n "$realpath" ]; then
                                mv -f $realpath $realpath.initramfs
                                mv -f $realpath.bak $realpath
                                ln -sf $linkpath.initramfs ${B}/${KERNEL_OUTPUT_DIR}/$imageType.initramfs
                        else
                                mv -f ${KERNEL_OUTPUT_DIR}/$imageType ${KERNEL_OUTPUT_DIR}/$imageType.initramfs
                                mv -f ${KERNEL_OUTPUT_DIR}/$imageType.bak ${KERNEL_OUTPUT_DIR}/$imageType
                        fi
                done
        fi
}
do_bundle_initramfs[dirs] = "${B}"

do_deploy() {
	:
}

addtask bundle_initramfs after do_install before do_deploy
addtask deploy after do_install
addtask shared_workdir after do_compile before do_install
addtask compile_kernelmodules
