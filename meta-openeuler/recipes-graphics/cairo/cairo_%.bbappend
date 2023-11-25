# bbfile: yocto-poky/meta/recipes-graphics/cairo/cairo_1.16.0.bb

OPENEULER_SRC_URI_REMOVE = "http"

# version in src-openEuler
PV = "1.17.4"

SRC_URI_remove = "file://CVE-2018-19876.patch \
           file://CVE-2020-35492.patch \
"

SRC_URI_prepend = "file://${BP}.tar.xz \
        file://0001-Set-default-LCD-filter-to-FreeType-s-default.patch \
        file://backport-CVE-2020-35492.patch \
        file://bugfix-cairo-truetype-reverse-cmap-detected-memory-leaks.patch \
        file://bugfix-fix-read-memory-access.patch \
        file://bugfix-fix-call-get_unaligned_be32-heap-buffer-overflow.patch \
        file://bugfix-fix-heap-buffer-overflow-in-cairo_cff_parse_charstring.patch \
"

SRC_URI[md5sum] = "bf9d0d324ecbd350d0e9308125fa4ce0"
SRC_URI[sha256sum] = "74b24c1ed436bbe87499179a3b27c43f4143b8676d8ad237a6fa787401959705"