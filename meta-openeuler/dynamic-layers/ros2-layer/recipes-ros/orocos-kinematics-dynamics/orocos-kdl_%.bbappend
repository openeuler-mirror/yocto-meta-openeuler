FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

FILES:${PN}-dev += "${libdir}/liborocos-kdl.so"

LIC_FILES_CHKSUM = "file://package.xml;beginline=14;endline=14;md5=d94c5c8f30151b2fe7d07ba53ed6444b"
#note 0001-include_project_name.patch is for 3.3.3
S = "${WORKDIR}/git/orocos_kdl"
