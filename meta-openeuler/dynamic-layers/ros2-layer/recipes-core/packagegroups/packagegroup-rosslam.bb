SUMMARY = "ros2 pkgs to support originbot slam"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS_${PN} = " \
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
nav2-bringup \
suitesparse-btf \
suitesparse-klu \
suitesparse-umfpack \
"
