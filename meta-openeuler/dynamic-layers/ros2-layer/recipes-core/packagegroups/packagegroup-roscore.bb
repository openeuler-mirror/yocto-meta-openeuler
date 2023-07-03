SUMMARY = "ros2 pkgs of ros-core and base demo"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
ros-core \
demo-nodes-cpp \
"
