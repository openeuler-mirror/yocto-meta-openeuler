# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/sysbench/sysbench_0.4.12.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"
DEPENDS = "libtool luajit concurrencykit"

inherit pkgconfig

PV = "1.0.20"

S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:remove = "https://launchpad.net/ubuntu/+archive/primary/+files/${BPN}_${PV}.orig.tar.gz \
                  file://0001-Adding-volatile-modifier-to-tmp-variable-in-memory-t.patch \
                  "
SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
                   "
SRC_URI[sha256sum] = "e8ee79b1f399b2d167e6a90de52ccc90e52408f7ade1b9b7135727efe181347f"

# the internal luajit won't cross compile
EXTRA_OECONF += "--with-system-luajit"

# lua.h generated files are bogus when using B != S
B = "${S}"
