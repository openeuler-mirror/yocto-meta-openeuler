SUMMARY = "ros2 pkgs of ros camera demo"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS_${PN} = " \
libuvc \
camera-calibration-parsers \
camera-info-manager \
v4l2-camera \
image-transport \
cv-bridge \
image-geometry \
vision-opencv \
image-publisher \
image-transport-plugins \
"
