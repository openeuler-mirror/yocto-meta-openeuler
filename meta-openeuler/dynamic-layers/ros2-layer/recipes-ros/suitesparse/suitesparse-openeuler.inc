#reference: yocto-meta-ros/meta-ros-common/recipes-extended/suitesparse/suitesparse-5.4.0.inc
inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "suitesparse"

SUITESPARSE_PV = "5.10.1"

SRC_URI:prepend = " file://suitesparse/SuiteSparse-${SUITESPARSE_PV}.tar.gz "

LIC_FILES_CHKSUM = "file://../LICENSE.txt;md5=5fa987762101f748a6cdd951b64ffc6b"
