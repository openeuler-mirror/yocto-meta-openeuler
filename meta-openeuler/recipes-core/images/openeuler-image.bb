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

#not add run-postinsts to PACKAGE_INSTALL, so that not fail when do_rootfs??
ROOTFS_BOOTSTRAP_INSTALL = ""

#not depends to update-alternatives
do_rootfs[depends] = ""
#not depends to ldconfig-native
#LDCONFIGDEPEND = ""
DEPENDS_remove += "qemuwrapper-cross depmodwrapper-cross cross-localedef-native"
RPMROOTFSDEPENDS = ""
FEATURE_PACKAGES_tools-sdk_remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK_remove += "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"

#IMAGE_ROOTFS_SIZE ?= "8192"
#IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

TOOLCHAIN_HOST_TASK_task-populate-sdk-ext = ""
TOOLCHAIN_HOST_TASK = ""
OUTPUT_DIR = "${TOPDIR}/output"

delete_boot_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    pushd "${IMAGE_ROOTFS}"
    rm -f "${OUTPUT_DIR}"/initrd
    # remove /boot from rootfs for final image
    if [-d ./boot]; then
        rm -f "${OUTPUT_DIR}"/Image* "${OUTPUT_DIR}"/vmlinux*
        mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
        mv boot/vmlinux* "${OUTPUT_DIR}"/
        mv boot/Image* "${OUTPUT_DIR}"/
        rm -r ./boot
    fi
    popd
}

copy_openeuler_distro() {
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} "${OUTPUT_DIR}"/initrd
}

IMAGE_PREPROCESS_COMMAND += "delete_boot_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"

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
openssh-ssh \
openssh-sshd \
openssh-scp \
shadow \
shadow-securetty \
bash \
pam-plugin-access \
pam-plugin-debug \
pam-plugin-deny \
pam-plugin-echo \
pam-plugin-env \
pam-plugin-exec \
pam-plugin-faildelay \
pam-plugin-faillock \
pam-plugin-filter \
pam-plugin-ftp \
pam-plugin-group \
pam-plugin-issue \
pam-plugin-keyinit \
pam-plugin-lastlog \
pam-plugin-limits \
pam-plugin-listfile \
pam-plugin-localuser \
pam-plugin-loginuid \
pam-plugin-mail \
pam-plugin-mkhomedir \
pam-plugin-motd \
pam-plugin-namespace \
pam-plugin-nologin \
pam-plugin-permit \
pam-plugin-pwhistory \
pam-plugin-rhosts \
pam-plugin-rootok \
pam-plugin-securetty \
pam-plugin-setquota \
pam-plugin-shells \
pam-plugin-stress \
pam-plugin-succeed-if \
pam-plugin-time \
pam-plugin-timestamp \
pam-plugin-umask \
pam-plugin-unix \
pam-plugin-usertype \
pam-plugin-warn \
pam-plugin-wheel \
pam-plugin-xauth \
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
kernel-module-overlay-5.10.0 \
kernel-img \
"

IMAGE_INSTALL += "${ROOTFS_BOOTSTRAP_INSTALL} ${IMAGE_INSTALL_normal} ${IMAGE_INSTALL_pro}"

DISTRO_FEATURES += "glibc"
