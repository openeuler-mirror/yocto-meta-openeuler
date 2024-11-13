# the main bb file: yocto-meta-openembedded/meta-oe/recipes-multimedia/webm/libvpx_1.11.0.bb

PV = "1.14.1"

SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://add-riscv64-arch.patch \
"

S = "${WORKDIR}/${BP}"

# sync from meta-oe/recipes-multimedia/webm/libvpx_1.13.0.bb
BUILD_LDFLAGS += "-pthread"
BBCLASSEXTEND += "native"
