# main bbfile: yocto-poky/meta/recipes-support/libatomic-ops/libatomic-ops_7.6.10.bb

PV = "7.8.2"

# license checksum changed
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://LICENSE;md5=5700d28353dfa2f191ca9b1bd707865e \
                    "

# apply src and patch from openEuler
SRC_URI:prepend = "file://libatomic_ops-${PV}.tar.gz \
	       file://0001-add-sw_64-support.patch \
	       "
