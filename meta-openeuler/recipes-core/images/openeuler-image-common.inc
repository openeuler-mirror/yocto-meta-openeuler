include recipes-core/images/${MACHINE}.inc
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

inherit core-image extrausers

# override the value in core-image.bbclass
# FEATURE_PACKAGES_tools-debug = ""

# by default user should reset root password at first login
# although the default password is empty, the password policy
# will require reset password immediately
OPENEUELR_IMAGE_USERS ?= " \
    usermod -p '' root; \
    passwd-expire root; \
                    "
# by default, allow root login and empty password from ssh
# because of the configuration of OPENEUELR_IMAGE_USERS
# root password will be required to reset at first login
OPENEULER_IMAGE_FEATURES ?= "allow-root-login allow-empty-password"
IMAGE_FEATURES:append = " ${OPENEULER_IMAGE_FEATURES}"

# image-level user and user group configuration
EXTRA_USERS_PARAMS = '${@bb.utils.contains_any("IMAGE_FEATURES", [ 'debug-tweaks', 'empty-root-password' ], "", "${OPENEUELR_IMAGE_USERS}; ",d)}'

# when debug-tweaks or tools_debug is in IMAGE_FEATURES, it means the image is used for debug
# so packagegroup-core-tools-debug(gdb and gdbserver) will be included.
# For image which is used for deployment, and debug related functions are not required, pls
# remove debug-tweaks and tool_debug from IMAGE_FEATURES
# FEATURE_PACKAGES_tools-debug in image.bbclass may do similar work, but her override it to
# meet openeuler embedded's need.
IMAGE_INSTALL:append = " ${@bb.utils.contains_any("IMAGE_FEATURES", [ 'debug-tweaks', 'tools_debug' ], "packagegroup-core-tools-debug", "",d)}"

# delete useless sdk depends
FEATURE_PACKAGES:tools-sdk:remove = " packagegroup-core-sdk packagegroup-core-standalone-sdk-target"
TOOLCHAIN_TARGET_TASK:remove = "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"


### prebuild tools use
# do_rootfs not depends to ldconfig-native as nativesdk has provided it
# learn more about LDCONFIGDEPEND in image.bbclass
LDCONFIGDEPEND:openeuler-prebuilt = ""

# no depends on some native tools: cross-localdef-native
DEPENDS:remove = "${@['', 'cross-localedef-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"
SDK_DEPENDS:remove = "${@['', '${SDK_ARCHIVE_DEPENDS} cross-localedef-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

# rpm depends
RPMROOTFSDEPENDS:openeuler-prebuilt = ""

# rootfs_rpm.bbclass line 14
# as we use dnf in hosttools, we don't need python3-native
# directly use python3 in prebuilt hosttools
EXTRANATIVEPATH:remove = "${@['', 'python3-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"


### OUTPUT_DIR point to image installation directory
OUTPUTTIME = "${DATETIME}"
# Ignore how DATETIME is computed
OUTPUTTIME[vardepsexclude] = "DATETIME"
OUTPUT_DIR = "${TOPDIR}/output/${OUTPUTTIME}"
# Ignore how TOPDIR is computed
OUTPUT_DIR[vardepsexclude] = "TOPDIR"

IMAGE_PREPROCESS_COMMAND += "set_permissions_from_rootfs;"

set_permissions_from_rootfs() {
   cd "${IMAGE_ROOTFS}"
   # set file permission for secure configuration
   chmod 750 ./etc/init.d
   cd -
}

DISTRO_FEATURES += "${TCLIBC}"
