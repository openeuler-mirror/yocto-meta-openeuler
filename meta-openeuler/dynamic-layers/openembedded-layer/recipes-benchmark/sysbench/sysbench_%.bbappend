# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/sysbench/sysbench_0.4.12.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PV = "1.0.20"

S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:remove = "file://0001-Adding-volatile-modifier-to-tmp-variable-in-memory-t.patch \
                  "
SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
                   "
SRC_URI[sha256sum] = "e8ee79b1f399b2d167e6a90de52ccc90e52408f7ade1b9b7135727efe181347f"


# from sysbench_1.0.20.bb
inherit pkgconfig

B = "${S}"

DEPENDS = "libtool luajit concurrencykit"

COMPATIBLE_HOST = "(arm|aarch64|i.86|x86_64).*-linux*"

EXTRA_OECONF += "--enable-largefile --with-system-luajit --with-system-ck --without-gcc-arch --with-lib-prefix=no"

PACKAGECONFIG ?= ""
