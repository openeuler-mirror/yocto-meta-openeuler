PV = "2.4.8"

SRC_URI[sha256sum] = "398f6d95bf808d3108e27547b372cb4ac8dc2298a3c4251eb7aa3d4c6d4bb3e2"

# patches from openeuler
SRC_URI = " \
    ${SOURCEFORGE_MIRROR}/expat/expat-${PV}.tar.gz \
    file://backport-0001-CVE-2022-40674.patch \
    file://backport-0002-CVE-2022-40674.patch \
"

# patch from poky
SRC_URI += " \
           file://libtool-tag.patch \
"
