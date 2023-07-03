FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://00-ydlidar-ros2-driver-fix-error.patch \
        "

ROS_BUILD_DEPENDS += " \
    rosidl-adapter \
    ydlidar \
"

ROS_EXPORT_DEPENDS += " \
    ydlidar \
"

ROS_EXEC_DEPENDS += " \
    ydlidar \
"

FILES:${PN} += "/usr/share /usr/lib"
