SUMMARY = "ros2 pkgs to support slam"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
ros-core \
demo-nodes-cpp \
cartographer-ros \
"
# now the upstream ros layer bas not bb file in humble, so remove it from packagegroup as a workaround
# nav2-bringup
