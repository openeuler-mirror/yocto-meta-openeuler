# bbfile: yocto-poky/meta/recipes-support/libbsd/libbsd_0.11.5.bb

PV = "0.12.2"

LIC_FILES_CHKSUM = "file://COPYING;md5=9b087a0981a1fcad42efbba6d4925a0f"

SRC_URI = " \
        file://${BP}.tar.xz \
"

SRC_URI[md5sum] = "1aa07d44ee00e2cc1ae3ac10baae7a68"
SRC_URI[sha256sum] = "b88cc9163d0c652aaf39a99991d974ddba1c3a9711db8f1b5838af2a14731014"

# To be fixed by llvm building
TOOLCHAIN:class-native = "gcc"
