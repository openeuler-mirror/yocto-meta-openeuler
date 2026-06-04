# bbfile: yocto-poky/meta/recipes-connectivity/iw/iw_5.16.bb

PV = "5.19"

SRC_URI = "file://iw-${PV}.tar.gz"

SRC_URI[sha256sum] = "2a44676d28a87bbc232903d5d573e7618e4fae0cea3a1aff067a26fa66652b75"

ASSUME_PROVIDE_PKGS = "iw"
