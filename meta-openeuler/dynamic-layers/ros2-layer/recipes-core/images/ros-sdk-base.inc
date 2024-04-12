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
protobuf-c \
libtool \
libogg \
libtheora \
libusb-compat \
"

