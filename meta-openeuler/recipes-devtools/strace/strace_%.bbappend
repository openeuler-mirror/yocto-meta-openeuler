# main bbfile: yocto-poky/meta/recipes-devtools/strace/strace_5.16.bb

# strace version in openEuler
PV = "6.6"

# strace 6.6 has different COPYING md5 than 6.7
LIC_FILES_CHKSUM = "file://COPYING;md5=63c8c3eb5c71b4362edac1397f40bdc7"

# remove conflict patch from scarthgap recipe
SRC_URI:remove = " \
        file://Makefile-ptest.patch \
"

SRC_URI:append = "file://${BP}.tar.xz \
"
