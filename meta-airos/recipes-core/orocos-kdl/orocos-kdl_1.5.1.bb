SUMMARY = "Orocos kinematics dynamics"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=a8ffd58e6eb29a955738b8fcc9e9e8f2"

DEPENDS += " \
  libeigen \
  "

SRC_URI = " \
	file://v1.5.1.tar.gz \
	"

S = "${WORKDIR}/orocos_kinematics_dynamics-1.5.1/orocos_kdl"
inherit cmake

FILES:${PN}:append = " /usr/include /usr/lib64 /usr/share /usr/share/orocos_kdl/* "