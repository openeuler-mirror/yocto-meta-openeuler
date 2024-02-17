# the main bb file: yocto-poky/meta/recipes-support/gmp/gmp_6.2.1.bb

PV = "6.3.0"

# use poky patch
SRC_URI = "file://use-includedir.patch \
           file://0001-Append-the-user-provided-flags-to-the-auto-detected-.patch \
           file://0001-confiure.ac-Believe-the-cflags-from-environment.patch \
"


SRC_URI:append = "file://${BP}.tar.xz \
"

SRC_URI[md5sum] = "956dc04e864001a9c22429f761f2c283"
SRC_URI[sha256sum] = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
