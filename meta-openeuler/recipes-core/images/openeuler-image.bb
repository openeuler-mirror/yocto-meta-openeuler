SUMMARY = "A small image just capable of allowing a device to boot."

#IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_INSTALL = ""

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
#delete depends to cpio-native
do_image_cpio[depends] = ""

inherit populate_sdk
#set IMAGE_LOCALES_ARCHIVE to 0 and unset SDKIMAGE_LINGUAS, to avoid run generate_locale_archive()
IMAGE_LOCALES_ARCHIVE = "0"
SDKIMAGE_LINGUAS = ""
SDK_RELOCATE_AFTER_INSTALL = "0"

inherit populate_sdk_ext
export SDK_OS = "linux"
TOOLCHAIN_HOST_TASK_task-populate-sdk-ext = ""
TOOLCHAIN_HOST_TASK = " \
meta-environment-${MACHINE} \
"
FEATURE_PACKAGES_tools-sdk_remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK_remove += "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"


#not add run-postinsts to PACKAGE_INSTALL, so that not fail when do_rootfs??
ROOTFS_BOOTSTRAP_INSTALL = ""

#not depends to update-alternatives
do_rootfs[depends] = ""
#not depends to ldconfig-native
#LDCONFIGDEPEND = ""
#not depends to lib32-qemuwrapper-cross when no other lib32 pkgs
DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])} cross-localedef-native"
SDK_DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])}"
RPMROOTFSDEPENDS = ""

#IMAGE_ROOTFS_SIZE ?= "8192"
#IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

OUTPUT_DIR = "${TOPDIR}/output"

#No kernel-abiversion file found, cannot run depmod, aborting
USE_DEPMOD = "0"

ROOTFS_BOOTSTRAP_INSTALL = " \
busybox-linuxrc \
kernel \
busybox \
os-base \
glibc \
"

IMAGE_INSTALL_normal = " \
audit \
auditd \
audispd-plugins \
cracklib \
libpwquality \
libpam \
packagegroup-pam-plugins \
openssh-ssh \
openssh-sshd \
openssh-scp \
shadow \
shadow-securetty \
bash \
"
IMAGE_INSTALL_normal_append_arm += "kernel-module-unix"

IMAGE_INSTALL_pro = " \
${IMAGE_INSTALL_normal} \
libseccomp \
libwebsockets \
yajl \
lcr \
lxc \
libevhtp \
libarchive \
libevent \
iSulad \
kernel-module-overlay \
kernel-img \
kernel-vmlinux \
"

IMAGE_INSTALL += "${ROOTFS_BOOTSTRAP_INSTALL} ${IMAGE_INSTALL_normal} ${IMAGE_INSTALL_pro}"

DISTRO_FEATURES += "glibc"

copy_opeueuler_sdk() {
   cp -fp ${SDKDEPLOYDIR}/${TOOLCHAIN_OUTPUTNAME}.sh "${OUTPUT_DIR}"/
}
SDK_POSTPROCESS_COMMAND += "copy_opeueuler_sdk;"

require recipes-core/images/${MACHINE}.inc
