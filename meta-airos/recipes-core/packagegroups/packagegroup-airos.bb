SUMMARY = "packages for airos"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
ethercat-igh \
orocos-toolchain \
orocos-kdl \
robot-brain \
"
