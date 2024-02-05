#
# Generated by ros2recipe.py
#
# Copyright openeuler

inherit ros_distro_humble
inherit ros_superflore_generated

DESCRIPTION = "     The teb_local_planner package implements a plugin     to the base_local_planner of the 2D navigation stack.     The underlying method called Timed Elastic Band locally optimizes     the robot's trajectory with respect to trajectory execution time,     separation from obstacles and compliance with kinodynamic constraints at runtime.	   "
AUTHOR = "Christoph Rösmann"
ROS_AUTHOR = "Christoph Rösmann, "
HOMEPAGE = "http://wiki.ros.org/teb_local_planner"
SECTION = "devel"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://package.xml;beginline=17;endline=17;md5=d566ef916e9dedc494f5f793a6690ba5"

ROS_CN = ""
PV = "0.9.1"
ROS_BPN = "teb-local-planner"

ROS_BUILD_DEPENDS = " \
    builtin-interfaces \
    costmap-converter \
    costmap-converter-msgs \
    dwb-critics \
    geometry-msgs \
    libg2o \
    nav2-bringup \
    nav2-core \
    nav2-costmap-2d \
    nav2-msgs \
    nav2-util \
    pluginlib \
    rclcpp \
    rclcpp-action \
    rclcpp-lifecycle \
    std-msgs \
    teb-msgs \
    tf2 \
    tf2-eigen \
    visualization-msgs \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
"

ROS_EXPORT_DEPENDS = " \
    builtin-interfaces \
    costmap-converter \
    costmap-converter-msgs \
    dwb-critics \
    geometry-msgs \
    libg2o \
    nav2-bringup \
    nav2-core \
    nav2-costmap-2d \
    nav2-msgs \
    nav2-util \
    pluginlib \
    rclcpp \
    rclcpp-action \
    rclcpp-lifecycle \
    std-msgs \
    teb-msgs \
    tf2 \
    tf2-eigen \
    visualization-msgs \
"

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    builtin-interfaces \
    costmap-converter \
    costmap-converter-msgs \
    dwb-critics \
    geometry-msgs \
    libg2o \
    nav2-bringup \
    nav2-core \
    nav2-costmap-2d \
    nav2-msgs \
    nav2-util \
    pluginlib \
    rclcpp \
    rclcpp-action \
    rclcpp-lifecycle \
    std-msgs \
    teb-msgs \
    tf2 \
    tf2-eigen \
    visualization-msgs \
"

# Currently informational only -- see http://www.ros.org/reps/rep-0149.html#dependency-tags.
ROS_TEST_DEPENDS = " \
    ament-cmake-gtest \
"

DEPENDS = "${ROS_BUILD_DEPENDS} ${ROS_BUILDTOOL_DEPENDS}"
# Bitbake doesn't support the "export" concept, so build them as if we needed them to build this package (even though we actually
# don't) so that they're guaranteed to have been staged should this package appear in another's DEPENDS.
DEPENDS += "${ROS_EXPORT_DEPENDS} ${ROS_BUILDTOOL_EXPORT_DEPENDS}"

RDEPENDS:${PN} += "${ROS_EXEC_DEPENDS}"

OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR = "teb_local_planner"

DISABLE_OPENEULER_SOURCE_MAP = "1"

SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/teb_local_planner/teb_local_planner-630a22e.tar.gz \
"

S = "${WORKDIR}/teb_local_planner/teb_local_planner"

DEPENDS += "ceres-solver"

FILES:${PN} += "${datadir} ${libdir}/teb_local_planner/*.py"

CXXFLAGS += " -Wno-error=deprecated -Wno-error=maybe-uninitialized -Wno-error=deprecated-declarations -Wno-error=format-security"

ROS_BUILD_TYPE = "ament_cmake"

inherit ros_${ROS_BUILD_TYPE}

