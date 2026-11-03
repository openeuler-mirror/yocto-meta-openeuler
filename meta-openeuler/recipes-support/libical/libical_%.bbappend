# main bb yocto-poky/meta/recipes-support/libical/libical_3.0.16.bb

PV = "3.0.20"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://libical-bugfix-timeout-found-by-fuzzer.patch \
"
LIC_FILES_CHKSUM = "file://LICENSE.LGPL21.txt;md5=8f690bb538f4b301d931374a6eb864d0"
