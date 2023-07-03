# main bbfile: yocto-poky/meta/recipes-multimedia/libpng/libpng_1.6.39.bb

# source change to openEuler
SRC_URI:remove = "${SOURCEFORGE_MIRROR}/${BPN}/${BPN}${LIBV}/${BP}.tar.xz"

PV = "1.6.38"

LIC_FILES_CHKSUM = "file://LICENSE;md5=5c900cc124ba35a274073b5de7639b13"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://libpng-multilib.patch \
           file://CVE-2019-6129.patch \
"

# check value
SRC_URI[md5sum] = "564aa9f6c678dbb016b07ecfae8b7245"
SRC_URI[sha256sum] = "ca74a0dace179a8422187671aee97dd3892b53e168627145271cad5b5ac81307"
