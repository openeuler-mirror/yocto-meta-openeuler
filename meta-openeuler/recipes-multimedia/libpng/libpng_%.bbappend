# main bbfile: yocto-poky/meta/recipes-multimedia/libpng/libpng_1.6.37.bb

# source change to openEuler
SRC_URI_remove = "${SOURCEFORGE_MIRROR}/${BPN}/${BPN}${LIBV}/${BP}.tar.xz"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI_prepend = "file://${BP}.tar.gz \
           file://libpng-multilib.patch \
           file://CVE-2019-6129.patch \
           file://backport-avoid-random-test-failure.patch \
"

# check value
SRC_URI[md5sum] = "564aa9f6c678dbb016b07ecfae8b7245"
SRC_URI[sha256sum] = "ca74a0dace179a8422187671aee97dd3892b53e168627145271cad5b5ac81307"
