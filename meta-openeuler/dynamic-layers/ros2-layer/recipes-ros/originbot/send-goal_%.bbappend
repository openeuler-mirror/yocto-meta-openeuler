FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://00-send-goal-fix-compile-error.patch \
        "

ROS_BUILD_DEPENDS += " \
    rclcpp \
    rclcpp-action \
    rclcpp-components \
    nav2-msgs \
"

FILES:${PN} += "/usr/share /usr/lib"

