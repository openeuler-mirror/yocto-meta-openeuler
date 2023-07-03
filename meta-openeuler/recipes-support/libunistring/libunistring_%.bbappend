# main bbfile: yocto-poky/meta/recipes-support/libunistring/libunistring_1.0.bb

PV = "1.1"

# files, patches that come from openeuler
SRC_URI = " \
        file://${BP}.tar.xz;name=tarball \
"

SRC_URI[tarball.md5sum] = "db08bb384e81968957f997ec9808926e"
SRC_URI[tarball.sha256sum] = "eb8fb2c3e4b6e2d336608377050892b54c3c983b646c561836550863003c05d7"

LIC_FILES_CHKSUM = "file://COPYING.LIB;md5=6a6a8e020838b23406c81b19c1d46df6"