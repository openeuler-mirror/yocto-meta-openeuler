inherit ros_distro_humble 

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
   file://0001-Link-executables-against-shared-libs.patch \
   file://0002-Install-docs-into-subdirs.patch \
"

S = "${WORKDIR}/qhull-2015.2"
