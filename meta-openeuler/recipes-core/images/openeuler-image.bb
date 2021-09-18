SUMMARY = "A small image just capable of allowing a device to boot."

#IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_INSTALL = ""

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image
IMAGE_TYPES = "cpio"
IMAGE_FSTYPES_DEBUGFS = "cpio"
#tar:lower version has no --sort=name
IMAGE_CMD_tar = "${IMAGE_CMD_TAR} --format=posix --numeric-owner -cf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]"
#not depends to update-alternatives
do_rootfs[depends] = ""
#not depends to ldconfig-native
#LDCONFIGDEPEND = ""
DEPENDS_remove += "${@' '.join(["%s-qemuwrapper-cross" % m for m in d.getVar("MULTILIB_VARIANTS").split()])} qemuwrapper-cross depmodwrapper-cross cross-localedef-native"
RPMROOTFSDEPENDS = ""
FEATURE_PACKAGES_tools-sdk_remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK_remove += "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"

#IMAGE_ROOTFS_SIZE ?= "8192"
#IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

#do_package depends to command zstd
python do_package() {
    bb.note("do nothing");
}
#deltask package
#do_rootfs depends to command createrepo_c, so create an empty rootfs for do_image_tar
python do_rootfs() {
    bb.note("do nothing");
}
python do_image() {
    bb.note("depends to do_rootfs");
    workdir = d.getVar("WORKDIR")
    rootfs = os.path.join(workdir, "rootfs")
    if not os.path.exists(rootfs):
        os.makedirs(rootfs)
}

xxdo_image_complete() {
        :
}

IMAGE_INSTALL += " \
busybox \
linux-openeuler \
glibc \
zlib \
libcap-ng \
cracklib \
libpam \
audit \
libpwquality \
shadow \
openssh \
"
