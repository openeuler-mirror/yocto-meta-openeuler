# main bb yocto-poky/meta/recipes-support/libical/libical_3.0.16.bb

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://libical-bugfix-timeout-found-by-fuzzer.patch \
"
