# originbot-v1.0.2/originbot_deeplearning/body_tracking/body-tracking_0.0.0.bb 
#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "body tracking"
AUTHOR = "kao.zhu"
SECTION = "devel"
LICENSE = "Apache-License-2.0"
LIC_FILES_CHKSUM = "file://package.xml;beginline=8;endline=8;md5=12c26a18c7f493fdc7e8a93b16b7c04f"

ROS_CN = ""
PV = "0.0.0"
ROS_BPN = "body-tracking"

ROS_BUILD_DEPENDS = " \
    ai-msgs \
    geometry-msgs \
    rclcpp \
    rclcpp-action \
    rosidl-default-rutime \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
    rosidl-default-generators-native \
"

ROS_EXPORT_DEPENDS = ""

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    rosidl-default-rutime \
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

OPENEULER_LOCAL_NAME = "originbot-v1.0.2"

SRC_URI = " \
    file://originbot_deeplearning/body_tracking \
"

S = "${WORKDIR}/originbot_deeplearning/body_tracking"
ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}
