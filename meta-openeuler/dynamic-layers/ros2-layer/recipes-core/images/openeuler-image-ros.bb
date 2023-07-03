# build an iso image, the live-os uses openeuler-image-live, it must be the same as itself(openeuler-image)
# when LIVE_ROOTFS_TYPE defined, bug may come out in poky, so just use default value ext4 in image-live.bbclass.
# notice we need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES:append:aarch64 = " iso"
IMAGE_FSTYPES:append:x86-64 = " iso"
IMAGE_FSTYPES:remove:raspberrypi4 = "iso"
INITRD_IMAGE_LIVE = "openeuler-image-live"

# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES should be defined before openeuler-image-common.inc(before core-image and image.bbclass)
require recipes-core/images/openeuler-image-common.inc
# package sdk
require recipes-core/images/openeuler-image-sdk.inc

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put other class of packages to "packagegroup-xxx"
# Notice: IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
IMAGE_INSTALL += " \
packagegroup-roscore \
"
# current qemu can't support ros slam demo

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"

# * Add ROS Python packages and related development dependencies, including ament build tools and some ROS-dependent static libraries.
# * Why do they need to be added to the TOOLCHAIN_TARGET_TASK?
#   They are products of cross-compilation and belong to the target sysroot,
#   while ament packages and other Python dependency packages are used for build tools and are consistent with the host version.
TOOLCHAIN_TARGET_TASK += " \
ament-cmake \
ament-cmake-auto \
ament-cmake-core \
ament-cmake-export-definitions \
ament-cmake-export-dependencies \
ament-cmake-export-include-directories \
ament-cmake-export-interfaces \
ament-cmake-export-libraries \
ament-cmake-export-link-flags \
ament-cmake-export-targets \
ament-cmake-gmock \
ament-cmake-gtest \
ament-cmake-include-directories \
ament-cmake-libraries \
ament-cmake-pytest \
ament-cmake-python \
ament-cmake-ros \
ament-cmake-target-dependencies \
ament-cmake-test \
ament-cmake-version \
ament-cmake-gen-version-h \
ament-package \
python3-numpy \
python3-numpy-staticdev \
ceres-solver-staticdev \
foonathan-memory-staticdev \
libyaml-staticdev \
googletest \
"
