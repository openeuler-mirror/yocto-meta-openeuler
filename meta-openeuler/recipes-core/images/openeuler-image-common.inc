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

# rootfs_rpm.bbclass line 14
# as we use dnf in hosttools, we don't need python3-native
# directly use python3 in hosttools
EXTRANATIVEPATH:remove = "python3-native"


# by default user should reset root password at first login
# although the default password is empty, the password policy
# will require reset password immediately
OPENEUELR_IMAGE_USERS ?= " \
    usermod -p '' root; \
    passwd-expire root; \
"

# by default, allow root login and empty password from ssh
# because of the configuration of OPENEUELR_IMAGE_USERS
# root password will be required reset at first login
OPENEULER_IMAGE_FEATURES ?= "allow-root-login allow-empty-password"
IMAGE_FEATURES_append = " ${OPENEULER_IMAGE_FEATURES}"

# image-level user and user group configuration
# if the image contains debug-tweaks or empty-root-password feature
# the default user will be root and the password will be empty
# therefore, users can login without password
EXTRA_USERS_PARAMS = '${@bb.utils.contains_any("IMAGE_FEATURES", [ 'debug-tweaks', 'empty-root-password' ], "", "${OPENEUELR_IMAGE_USERS}; ",d)}'
