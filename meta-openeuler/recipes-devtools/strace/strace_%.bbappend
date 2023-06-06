# main bbfile: yocto-poky/meta/recipes-devtools/strace/strace_5.11.bb

# strace version in openEuler, this version needs to match the kernel
PV = "5.14"

# remove conflict patch
SRC_URI_remove = "file://Makefile-ptest.patch"

SRC_URI[md5sum] = "36c1c17f31855617b7898d2fd5abb9e2"
SRC_URI[sha256sum] = "901bee6db5e17debad4530dd9ffb4dc9a96c4a656edbe1c3141b7cb307b11e73"
