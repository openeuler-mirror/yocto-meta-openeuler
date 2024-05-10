# bbfile: yocto-poky/meta/recipes-support/libbsd/libbsd_0.11.5.bb

PV = "0.10.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=2120be0173469a06ed185b688e0e1ae0"

SRC_URI = " \
        file://${BP}.tar.xz \
        file://libbsd-symver.patch \
"

SRC_URI[md5sum] = "ead96d240d02faa5b921c0aa50c812b5"
SRC_URI[sha256sum] = "34b8adc726883d0e85b3118fa13605e179a62b31ba51f676136ecb2d0bc1a887"

# To be fixed by llvm building
TOOLCHAIN:class-native = "gcc"
