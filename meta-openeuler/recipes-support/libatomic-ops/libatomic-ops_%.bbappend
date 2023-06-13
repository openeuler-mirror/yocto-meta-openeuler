# main bbfile: yocto-poky/meta/recipes-support/libatomic-ops/libatomic-ops_7.6.10.bb

PV = "7.6.12"
OPENEULER_REPO_NAME = "libatomic_ops"

# apply src and patch from openEuler
SRC_URI = "file://libatomic_ops-${PV}.tar.gz \
	   file://libatomic_ops-7.6.12-sw.patch \
	  "

SRC_URI[md5sum] = "0b0b88da4bde5dd770daea3146e78359"
SRC_URI[sha256sum] = "f0ab566e25fce08b560e1feab6a3db01db4a38e5bc687804334ef3920c549f3e"

# license checksum changed
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://doc/LICENSING.txt;md5=e00dd5c8ac03a14c5ae5225a4525fa2d \
                    "
