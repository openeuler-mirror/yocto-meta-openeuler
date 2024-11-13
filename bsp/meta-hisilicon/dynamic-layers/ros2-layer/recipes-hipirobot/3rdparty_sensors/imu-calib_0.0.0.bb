#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "Package for computing and applying IMU calibrations"
AUTHOR = "Daniel Koch"
ROS_AUTHOR = "Daniel Koch, "
SECTION = "devel"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://package.xml;beginline=10;endline=10;md5=d566ef916e9dedc494f5f793a6690ba5"

ROS_CN = ""
PV = "0.0.0"
ROS_BPN = "imu-calib"

ROS_BUILD_DEPENDS = " \
    libeigen \
    rclcpp \
    sensor-msgs \
    yaml-cpp-vendor \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
"

ROS_EXPORT_DEPENDS = " \
    libeigen \
    rclcpp \
    sensor-msgs \
    yaml-cpp-vendor \
"

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    libeigen \
    rclcpp \
    sensor-msgs \
    yaml-cpp-vendor \
"

# Currently informational only -- see http://www.ros.org/reps/rep-0149.html#dependency-tags.
ROS_TEST_DEPENDS = ""

DEPENDS = "${ROS_BUILD_DEPENDS} ${ROS_BUILDTOOL_DEPENDS}"
# Bitbake doesn't support the "export" concept, so build them as if we needed them to build this package (even though we actually
# don't) so that they're guaranteed to have been staged should this package appear in another's DEPENDS.
DEPENDS += "${ROS_EXPORT_DEPENDS} ${ROS_BUILDTOOL_EXPORT_DEPENDS}"

RDEPENDS:${PN} += "${ROS_EXEC_DEPENDS}"

OPENEULER_LOCAL_NAME = "hieuler_3rdparty_sensors"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/imu/imu_process/imu_calib \
"

S = "${WORKDIR}/hieuler_3rdparty_sensors/imu/imu_process/imu_calib"
DISABLE_OPENEULER_SOURCE_MAP = "1"
FILES:${PN} += "${datadir} ${libdir}/imu_calib/*"
ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}
