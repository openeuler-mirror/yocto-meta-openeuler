# the main bb file: yocto-meta-openembedded/meta-oe/recipes-multimedia/webm/libvpx_1.11.0.bb

PV = "1.13.1"

SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://add-riscv64-arch.patch \
    file://CVE-2024-5197-pre1.patch \
    file://CVE-2024-5197-1.patch \
    file://CVE-2024-5197-2.patch \
    file://CVE-2024-5197-3.patch \
"

S = "${WORKDIR}/${BP}"

# sync from meta-oe/recipes-multimedia/webm/libvpx_1.13.0.bb
BUILD_LDFLAGS += "-pthread"
BBCLASSEXTEND += "native"

