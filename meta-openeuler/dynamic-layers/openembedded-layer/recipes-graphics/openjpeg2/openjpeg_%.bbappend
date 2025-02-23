# main bb: yocto-meta-openembedded/meta-oe/recipes-graphics/openjpeg/openjpeg_%.bb

OPENEULER_LOCAL_NAME = "openjpeg2"

PV = "2.5.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=c648878b4840d7babaade1303e7f108c"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://backport-CVE-2023-39328.patch \
        file://backport-CVE-2021-3575.patch \
        file://backport-CVE-2024-56826.patch \
        file://backport-CVE-2024-56827.patch \
"

S = "${WORKDIR}/${BP}"
