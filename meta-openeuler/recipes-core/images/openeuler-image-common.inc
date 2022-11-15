IMAGE_INSTALL = ""

# no extra language settings
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES ?= "cpio.gz"
IMAGE_FSTYPES_DEBUGFS ?= "cpio.gz"
INITRAMFS_MAXSIZE ?= "262144"

inherit core-image

#delete useless sdk depends
FEATURE_PACKAGES_tools-sdk_remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK_remove += "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"

#not depends to native tools like, update-alternatives, update-rc.d as they are provided by nativesdk
do_rootfs[depends] = ""

#no depends on some native tools: cross-localdef-native
DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])} cross-localedef-native"
SDK_DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])}"
RPMROOTFSDEPENDS = ""


OUTPUTTIME = "${DATETIME}"
# Ignore how DATETIME is computed
OUTPUTTIME[vardepsexclude] = "DATETIME"
OUTPUT_DIR = "${TOPDIR}/output/${OUTPUTTIME}"

# do not use depmod
USE_DEPMOD = "0"

IMAGE_PREPROCESS_COMMAND += "set_permissions_from_rootfs;"

set_permissions_from_rootfs() {
   pushd "${IMAGE_ROOTFS}"
   # set file permissions for secure
   chmod 750 ./etc/init.d
   popd
}

DISTRO_FEATURES += "${LIBC}"
