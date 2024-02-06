# openeuler standard image packages
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-core-base-utils \
packagegroup-base \
packagegroup-openssh \
packagegroup-network \
packagegroup-kernel-modules \
packagegroup-dsoftbus \
"
# add VIRTUAL-RUNTIME_dev_manager to avoid packagegroup-core-boot broken with systemd as a workaround
# to save space for emmc (limit 387M), disble:
# packagegroup-core-tools-debug 
# packagegroup-isulad 

# no extra language settings
IMAGE_LINGUAS = ""

LICENSE = "MIT"

inherit core-image extrausers

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
FEATURE_PACKAGES_debug-tweaks = "packagegroup-core-tools-debug"


# as prebuilt external toolchain (including glibc) is the default toolchain, so need to remove
# the packagegroup-core-standalone-sdk-target which is designed for native toolchain
# the recipe of external toolchain will set TOOLCHAIN_TARGET_TASK specifically.
# note: packagegroup-core-standalone-sdk-target and packagegroup-core-sdk needs to be handled in tcmode-external
FEATURE_PACKAGES_tools-sdk:tcmode-external = " "
TOOLCHAIN_TARGET_TASK:remove:tcmode-external = "${@multilib_pkg_extend(d, 'packagegroup-core-standalone-sdk-target')}"


### prebuilt tools use
# no depends on some native tools: cross-localdef-native
DEPENDS:remove = "${@['', 'cross-localedef-native']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

# do_rootfs not depends to ldconfig-native as prebuilt tools provided it
# learn more about LDCONFIGDEPEND in image.bbclass
LDCONFIGDEPEND:openeuler-prebuilt = ""

# rpm depends in rootfs_rpm.bbclass
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


# set file permission for secure configuration
set_permissions_from_rootfs() {
   cd "${IMAGE_ROOTFS}"
   chmod 750 ./etc/init.d
   cd -
}

require recipes-core/images/openeuler-image-sdk.inc

IMAGE_PREPROCESS_COMMAND += "set_permissions_from_rootfs;"

# specific machine configuration
include recipes-core/images/${MACHINE}.inc
