# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libtinyxml/libtinyxml_2.6.2.bb

# openeuler version
PV = "2.6.2"

OPENEULER_LOCAL_NAME = "tinyxml"

S = "${WORKDIR}/tinyxml"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += "file://tinyxml_2_6_2.tar.gz \
        file://CVE-2021-42260.patch \
        file://CVE-2023-34194.patch \
        "
