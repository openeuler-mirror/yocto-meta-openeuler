# version in src-openEuler
PV = "1.17.4"

SRC_URI:remove = "file://CVE-2018-19876.patch \
           file://CVE-2020-35492.patch \
"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://0001-Set-default-LCD-filter-to-FreeType-s-default.patch \
    file://backport-CVE-2020-35492.patch \
"

SRC_URI[md5sum] = "bf9d0d324ecbd350d0e9308125fa4ce0"
SRC_URI[sha256sum] = "74b24c1ed436bbe87499179a3b27c43f4143b8676d8ad237a6fa787401959705"
