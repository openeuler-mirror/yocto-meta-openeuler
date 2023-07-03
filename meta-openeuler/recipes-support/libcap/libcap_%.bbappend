PV = "2.66"

LIC_FILES_CHKSUM = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"
SRC_URI[sha256sum] = "5f65dc5b2e9f63a0748ea1b05be7965a38548db1cbfd53b30271ff02186b3a4a"

# openeuler package and patches
SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
    file://libcap-buildflags.patch \
"

# use cross compile objcopy
# set lib dir, not use ldd to find, maybe fail
EXTRA_OEMAKE:class-target = " \
    OBJCOPY="${OBJCOPY}" \ 
    lib="${base_libdir}" \
"
