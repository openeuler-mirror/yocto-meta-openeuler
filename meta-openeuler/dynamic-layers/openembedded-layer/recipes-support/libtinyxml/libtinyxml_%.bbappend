# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libtinyxml/libtinyxml_2.6.2.bb

# openeuler version
PV = "2.6.2"

OPENEULER_REPO_NAME = "tinyxml"

S = "${WORKDIR}/tinyxml"

SRC_URI += "file://tinyxml_2_6_2.tar.gz \
        file://CVE-2021-42260.patch \
        file://2-fix-devel-package-error.patch \
        "
