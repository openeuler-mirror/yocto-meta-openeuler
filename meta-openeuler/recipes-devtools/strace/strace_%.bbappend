# main bbfile: yocto-poky/meta/recipes-devtools/strace/strace_5.16.bb

# strace version in openEuler, this version needs to match the kernel
# do not use 6.x, not match 5.10 kernel
PV = "5.14"

LIC_FILES_CHKSUM = "file://COPYING;md5=318cfc887fc8723f4e9d4709b55e065b"

# remove conflict patch
SRC_URI:remove = " \
        file://Makefile-ptest.patch \
"

SRC_URI:append = "file://${BP}.tar.xz \
        file://strace-5.14-solve-ilp32-strace-build-error.patch \
"

SRC_URI[md5sum] = "36c1c17f31855617b7898d2fd5abb9e2"
SRC_URI[sha256sum] = "901bee6db5e17debad4530dd9ffb4dc9a96c4a656edbe1c3141b7cb307b11e73"
