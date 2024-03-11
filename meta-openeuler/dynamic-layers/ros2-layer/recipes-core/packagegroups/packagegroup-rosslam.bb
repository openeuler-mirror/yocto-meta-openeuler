SUMMARY = "ros2 pkgs to support originbot slam"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
ros-core \
demo-nodes-cpp \
originbot-navigation \
originbot-bringup \
originbot-msgs \
originbot-base \
originbot-teleop \
send-goal \
ydlidar-ros2-driver \
cartographer-ros \
"
# now the upstream ros layer bas not bb file in humble, so remove it from packagegroup as a workaround
# nav2-bringup
