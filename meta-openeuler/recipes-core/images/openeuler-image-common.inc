SUMMARY = "A small image just capable of allowing a device to boot."

IMAGE_INSTALL = ""

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
#delete depends to cpio-native
do_image_cpio[depends] = ""

#delete useless sdk depends
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

OUTPUTTIME = "${DATETIME}"
# Ignore how DATETIME is computed
OUTPUTTIME[vardepsexclude] = "DATETIME"
OUTPUT_DIR = "${TOPDIR}/output/${OUTPUTTIME}"

#No kernel-abiversion file found, cannot run depmod, aborting
USE_DEPMOD = "0"

# openEuler embedded uses pre-built dnf tool which is different with Yocto's patched dnf.
# Yocto's dnf is patched  with special handlings for yocto's build flow
# (see poky/meta/recipes-devtools/dnf).
# In prebuilt dnf, the log dir will be in the install dir of target rootfs, this will
# pollute the target rootfs. That's why 0005-Do-not-prepend-installroot-to-logdir.path is
# needed.
# in openEuler, we do some modifications (meta/lib/oe/package_manager/rpm/__init__.py),
# add a DNF_LOG_DIR to handle the case of prebuilt dnf.
# Through DNF_LOG_DIR, the dnf logs will be written in DNF_LOG_DIR of target rootfs.
# After the install of rootfs, these logs should be deleted to avoid pollution of target rootfs

# What's tricky, the logs of DNF can de divided into two parts, dnf*.log and hawky.log.
# dnf*.log's rootfs dir is the target rootfs dir, hawky.log's rootfs dir is the host rootfs dir.,
# i.e, hawky.log will be written into ${WORKDIR}/temp, dnf*.log will be written into ${WORKDIR}/rootfs
# ${WORKDIR}/temp. So a workaround here is set DNF_LOG_DIR = "/tmp", that both dnf*.log and hawky.log
# can be written successfully

DNF_LOG_DIR = "/tmp"

IMAGE_PREPROCESS_COMMAND += "delete_dnf_logs_from_rootfs;"

delete_dnf_logs_from_rootfs() {
   pushd "${IMAGE_ROOTFS}"
   if [ -e ./tmp/dnf.log ];then
      mv ./tmp/dnf*.log ${T}
   fi
   popd
}

DISTRO_FEATURES += "glibc"
