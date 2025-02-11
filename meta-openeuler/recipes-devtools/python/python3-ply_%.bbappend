# source bb: yocto-poky/meta/recipes-devtools/python/python3-ply_3.11.bb

PV = "3.11"

SRC_URI[md5sum] = "6465f602e656455affcd7c5734c638f8"
SRC_URI[sha256sum] = "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"

require pypi-src-openeuler.inc

OPENEULER_LOCAL_NAME = "${BPN}"
