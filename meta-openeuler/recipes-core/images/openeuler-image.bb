SUMMARY = "A small image just capable of allowing a device to boot."

#IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_INSTALL = ""

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image
IMAGE_TYPES = "cpio"
IMAGE_FSTYPES_DEBUGFS = "cpio"
#not add run-postinsts to PACKAGE_INSTALL, so that not fail when do_rootfs??
ROOTFS_BOOTSTRAP_INSTALL = ""
#tar:lower version has no --sort=name
IMAGE_CMD_tar = "${IMAGE_CMD_TAR} --format=posix --numeric-owner -cf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]"
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

fakeroot do_openeuler_initrd() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    local rootfs_dir="${WORKDIR}/rootfs_tmp"
    test -d "${rootfs_dir}" && rm -r "${rootfs_dir}"
    cp -a "${WORKDIR}/rootfs" "${rootfs_dir}"
    pushd "${rootfs_dir}"
    local imagename=$(ls boot/${KERNEL_IMAGETYPE}-* | xargs basename)
    rm -f "${OUTPUT_DIR}"/*Image "${OUTPUT_DIR}"/initrd
    mv boot/${imagename} "${OUTPUT_DIR}"/$(echo ${imagename} | cut -d "-" -f 1)
    mv boot/vmlinux* "${OUTPUT_DIR}"/
    mv boot/Image* "${OUTPUT_DIR}"/
    chmod +x etc/rc.d/*
    rm -r ./boot
    chown -R root:root ./*
    find . | cpio -H newc -o | gzip -c > "${OUTPUT_DIR}"/initrd
    popd
}
addtask do_openeuler_initrd after do_image_complete before do_build

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
