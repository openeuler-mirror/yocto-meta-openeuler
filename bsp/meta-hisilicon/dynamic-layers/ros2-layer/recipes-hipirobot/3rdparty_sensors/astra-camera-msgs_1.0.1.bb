#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "A package containing orbbec camera messages definitions."
AUTHOR = "Joe Dong"
SECTION = "devel"
LICENSE = "all-copyrights-reserved"
LIC_FILES_CHKSUM = "file://package.xml;beginline=8;endline=8;md5=dc598af4b0c94a75cbcc6b3d79c24b12"

ROS_CN = ""
PV = "1.0.1"
ROS_BPN = "astra-camera-msgs"

ROS_BUILD_DEPENDS = " \
    rosidl-default-generators \
    sensor-msgs \
    std-msgs \
    rosidl-adapter-native \
    ament-cmake-ros-native \
    python3-numpy-native \
    rosidl-generator-c-native \
    rosidl-generator-cpp-native \
    rosidl-typesupport-fastrtps-c-native \
    rosidl-typesupport-fastrtps-cpp-native \
    rosidl-typesupport-introspection-cpp-native \
    rosidl-typesupport-cpp-native \
    rosidl-generator-py-native \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
"

ROS_EXPORT_DEPENDS = " \
    rosidl-default-runtime \
    sensor-msgs \
    std-msgs \
"

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    rosidl-default-runtime \
    sensor-msgs \
    std-msgs \
"

# Currently informational only -- see http://www.ros.org/reps/rep-0149.html#dependency-tags.
ROS_TEST_DEPENDS = " \
    ament-lint-auto \
    ament-lint-common \
"

DEPENDS = "${ROS_BUILD_DEPENDS} ${ROS_BUILDTOOL_DEPENDS}"
# Bitbake doesn't support the "export" concept, so build them as if we needed them to build this package (even though we actually
# don't) so that they're guaranteed to have been staged should this package appear in another's DEPENDS.
DEPENDS += "${ROS_EXPORT_DEPENDS} ${ROS_BUILDTOOL_EXPORT_DEPENDS}"

RDEPENDS:${PN} += "${ROS_EXEC_DEPENDS}"

OPENEULER_LOCAL_NAME = "hieuler_3rdparty_sensors"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/3d_camera/astra_camera/ros2_astra_camera/astra_camera_msgs \
"
FILES:${PN} += "${datadir}"

S = "${WORKDIR}/hieuler_3rdparty_sensors/3d_camera/astra_camera/ros2_astra_camera/astra_camera_msgs"
DISABLE_OPENEULER_SOURCE_MAP = "1"
ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}

