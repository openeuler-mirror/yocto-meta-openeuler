PV = "2.61"

LIC_FILES_CHKSUM = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"
SRC_URI[sha256sum] = "4897da3617ab7a0364a82da7c8c5aa49be8129d84018df92f0982d1363a53758"

# openeuler package and patches
SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
    file://libcap-buildflags.patch \
    file://Fix-syntax-error-in-DEBUG-protected-setcap.c-code.patch \
    file://backport-psx-free-allocated-memory-at-exit.patch \
    file://backport-Avoid-a-deadlock-in-forked-psx-thread-exit.patch \
    file://backport-getpcaps-catch-PID-parsing-errors.patch \
"
# patches from poky
SRC_URI += " \
    file://0001-ensure-the-XATTR_NAME_CAPS-is-defined-when-it-is-use.patch \
"

# the version 2.61 add the follow patchs
SRC_URI_append_class-nativesdk = " \
    file://0001-nativesdk-libcap-Raise-the-size-of-arrays-containing.patch \
"

# BUILD_GPERF is now reserved, please use USE_GPERF=yes or no instead.
EXTRA_OEMAKE_remove = "BUILD_GPERF=yes \
"
EXTRA_OEMAKE_append = "USE_GPERF=yes \
"

# use cross compile objcopy
# set lib dir, not use ldd to find, maybe fail
EXTRA_OEMAKE_class-target = " \
    OBJCOPY="${OBJCOPY}" \ 
    lib="${base_libdir}" \
"
