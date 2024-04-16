# hieuler_component_ai/sample/camera/camera_0.0.0.bb 
#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "camera"
AUTHOR = "root"
SECTION = "devel"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://package.xml;beginline=8;endline=8;md5=782925c2d55d09052e1842a0b4886802"

ROS_CN = ""
PV = "0.0.0"
ROS_BPN = "camera"

ROS_BUILD_DEPENDS = " \
    hieulerpi1-user-driver \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
"

ROS_EXPORT_DEPENDS = ""

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    hieulerpi1-user-driver \
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

OPENEULER_LOCAL_NAME = "hieuler_component_ai"
SRC_URI = " \
    file://hieuler_component_ai/sample/camera \
    file://hieuler_component_ai \
    file://camera_fix.patch \
"

S = "${WORKDIR}/hieuler_component_ai/sample/camera"
DISABLE_OPENEULER_SOURCE_MAP = "1"
ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}

