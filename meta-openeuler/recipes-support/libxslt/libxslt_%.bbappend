# the main bb file: yocto-poky/meta/recipes-support/libxslt/libxslt_1.1.35.bb

PV = "1.1.42"

SRC_URI = " \
    file://${BP}.tar.xz \
    file://CVE-2015-9019.patch \
"

EXTRA_OECONF:remove = "--without-mem-debug --with-html-subdir=${BPN}"
