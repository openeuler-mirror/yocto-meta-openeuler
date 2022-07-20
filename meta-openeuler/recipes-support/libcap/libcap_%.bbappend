PV = "2.61"

LIC_FILES_CHKSUM = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"
SRC_URI[sha256sum] = "4897da3617ab7a0364a82da7c8c5aa49be8129d84018df92f0982d1363a53758"

# openeuler package and patches
SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
    file://libcap-buildflags.patch \
"
# patches from poky
SRC_URI += " \
    file://0001-ensure-the-XATTR_NAME_CAPS-is-defined-when-it-is-use.patch \
"

# use cross compile objcopy
# set lib dir, not use ldd to find, maybe fail
EXTRA_OEMAKE = " \
    OBJCOPY="${OBJCOPY}" \ 
    lib="${base_libdir}" \
"
