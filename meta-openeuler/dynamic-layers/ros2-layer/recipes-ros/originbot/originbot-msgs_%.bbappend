FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ROS_BUILD_DEPENDS += " \
    std-msgs \
"

ROS_BUILDTOOL_DEPENDS += " \
    rosidl-default-generators-native \
    rosidl-typesupport-fastrtps-cpp-native \
    rosidl-typesupport-fastrtps-c-native \
"

ROS_EXEC_DEPENDS = " \
    std-msgs \
"

FILES:${PN} += "/usr/share"
