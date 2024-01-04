PV = "1.2.1"
LIC_FILES_CHKSUM = "file://package.xml;beginline=14;endline=14;md5=12c26a18c7f493fdc7e8a93b16b7c04f"

ROS_BUILD_DEPENDS = " \
    rosidl-default-runtime \
"

ROS_BUILDTOOL_DEPENDS = " \
    ament-cmake-native \
    rosidl-default-generators-native \
"

ROS_EXPORT_DEPENDS = " \
    rosidl-default-runtime \
"

ROS_BUILDTOOL_EXPORT_DEPENDS = ""

ROS_EXEC_DEPENDS = " \
    rosidl-default-runtime \
"

OPENEULER_LOCAL_NAME = "hirobot_component_chassis"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/uart/ola/depend/serial_ros2 \
"

S = "${WORKDIR}/hirobot_component_chassis/uart/ola/depend/serial_ros2"

DISABLE_OPENEULER_SOURCE_MAP = "1"
