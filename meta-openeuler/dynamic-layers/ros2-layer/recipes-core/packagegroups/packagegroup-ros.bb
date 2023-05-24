SUMMARY = "ros2 pkgs of ros"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS_${PN} = " \
packagegroup-roscore \
${@bb.utils.contains("DISTRO_FEATURES", "ros-camera", "packagegroup-roscamera", "", d)} \
${@bb.utils.contains("DISTRO_FEATURES", "ros-slam", "packagegroup-rosslam", "", d)} \
"

