# main bbfile: yocto-poky/meta/recipes-support/libunistring/libunistring_0.9.10.bb

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/libunistring/libunistring-${PV}.tar.gz \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz;name=tarball \
"

SRC_URI[tarball.md5sum] = "db08bb384e81968957f997ec9808926e"
SRC_URI[tarball.sha256sum] = "eb8fb2c3e4b6e2d336608377050892b54c3c983b646c561836550863003c05d7"
