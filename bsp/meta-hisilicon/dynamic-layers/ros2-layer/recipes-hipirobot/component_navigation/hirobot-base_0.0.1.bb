#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "     Hirobot base node that include diff drive controller, odometry and tf node   "
AUTHOR = "HiRobot"
SECTION = "devel"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://package.xml;beginline=10;endline=10;md5=3dce4ba60d7e51ec64f3c3dc18672dd3"

ROS_CN = ""
PV = "0.0.1"
ROS_BPN = "hirobot-base"

ROS_BUILD_DEPENDS = " \
    geometry-msgs \
    hirobot-msgs \
    message-filters \
    nav-msgs \
    rclcpp \
    rcutils \
    sensor-msgs \
    std-msgs \
    std-srvs \
    tf2 \
    tf2-ros \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
    rosidl-default-generators-native \
"

ROS_EXPORT_DEPENDS = " \
    geometry-msgs \
    hirobot-msgs \
    message-filters \
    nav-msgs \
    rclcpp \
    rcutils \
    sensor-msgs \
    std-msgs \
    std-srvs \
    tf2 \
    tf2-ros \
"

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    geometry-msgs \
    hirobot-msgs \
    message-filters \
    nav-msgs \
    rclcpp \
    rcutils \
    sensor-msgs \
    std-msgs \
    std-srvs \
    tf2 \
    tf2-ros \
"

# Currently informational only -- see http://www.ros.org/reps/rep-0149.html#dependency-tags.
ROS_TEST_DEPENDS = ""

DEPENDS = "${ROS_BUILD_DEPENDS} ${ROS_BUILDTOOL_DEPENDS}"
# Bitbake doesn't support the "export" concept, so build them as if we needed them to build this package (even though we actually
# don't) so that they're guaranteed to have been staged should this package appear in another's DEPENDS.
DEPENDS += "${ROS_EXPORT_DEPENDS} ${ROS_BUILDTOOL_EXPORT_DEPENDS}"

RDEPENDS:${PN} += "${ROS_EXEC_DEPENDS}"

OPENEULER_LOCAL_NAME = "hirobot_component_navigation"
SRC_URI = " \
    file://hirobot_component_navigation/hirobot_base \
"

S = "${WORKDIR}/hirobot_component_navigation/hirobot_base"
FILES:${PN} += "${datadir} ${libdir}"
DISABLE_OPENEULER_SOURCE_MAP = "1"
ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}
