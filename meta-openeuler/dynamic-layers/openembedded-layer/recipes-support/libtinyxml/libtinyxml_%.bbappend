# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libtinyxml/libtinyxml_2.6.2.bb

# openeuler version
PV = "2.6.2"

OPENEULER_REPO_NAME = "tinyxml"

LIC_FILES_CHKSUM = "file://readme.txt;md5=f8f366f3370dda889f60faa7db162cf4"

S = "${WORKDIR}/tinyxml"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = "${SOURCEFORGE_MIRROR}/tinyxml/tinyxml_${@'${PV}'.replace('.', '_')}.tar.gz "

SRC_URI += "file://tinyxml_2_6_2.tar.gz \
        file://CVE-2021-42260.patch \
        "

