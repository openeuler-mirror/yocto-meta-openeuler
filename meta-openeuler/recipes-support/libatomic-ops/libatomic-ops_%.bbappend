# main bbfile: yocto-poky/meta/recipes-support/libatomic-ops/libatomic-ops_7.6.10.bb

PV = "7.6.14"

# license checksum changed
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://doc/LICENSING.txt;md5=dfc50c7cea7b66935844587a0f7389e7 \
                    "

# apply src and patch from openEuler
SRC_URI:prepend = "file://libatomic_ops-${PV}.tar.gz \
	       file://libatomic_ops-7.6.12-sw.patch \
	       "
