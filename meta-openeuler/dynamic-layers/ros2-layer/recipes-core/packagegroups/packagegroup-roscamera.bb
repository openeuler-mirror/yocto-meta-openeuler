SUMMARY = "ros2 pkgs of ros camera demo"
PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
libuvc \
camera-calibration-parsers \
camera-info-manager \
v4l2-camera \
image-transport \
cv-bridge \
image-transport-plugins \
"
