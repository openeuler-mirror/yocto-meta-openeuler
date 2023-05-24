require recipes-core/images/${MACHINE}.inc
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-core-base-utils \
packagegroup-core-tools-debug \
packagegroup-base \
packagegroup-openssh \
packagegroup-network \
packagegroup-kernel-modules \
packagegroup-isulad \
packagegroup-dsoftbus \
"

# no extra language settings
IMAGE_LINGUAS = ""

LICENSE = "MIT"

inherit core-image

# delete useless sdk depends
FEATURE_PACKAGES_tools-sdk_remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK_remove = "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"

# do_rootfs not depends to ldconfig-native as nativesdk has provided it
# learn more about LDCONFIGDEPEND in image.bbclass
LDCONFIGDEPEND = ""

# no depends on some native tools: cross-localdef-native
DEPENDS_remove = "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])} cross-localedef-native"
SDK_DEPENDS_remove = "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])}"
RPMROOTFSDEPENDS = ""


OUTPUTTIME = "${DATETIME}"
# Ignore how DATETIME is computed
OUTPUTTIME[vardepsexclude] = "DATETIME"
OUTPUT_DIR = "${TOPDIR}/output/${OUTPUTTIME}"
# Ignore how TOPDIR is computed
OUTPUT_DIR[vardepsexclude] = "TOPDIR"

IMAGE_PREPROCESS_COMMAND += "set_permissions_from_rootfs;"

set_permissions_from_rootfs() {
   cd "${IMAGE_ROOTFS}"
   # set file permissions for secure
   chmod 750 ./etc/init.d
   cd -
}

DISTRO_FEATURES += "${TCLIBC}"
