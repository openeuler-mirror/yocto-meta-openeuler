require libmetal.inc

SRC_URI:prepend = " \
        file://libmetal-add-additional-arches.patch \
        file://add-riscv-support.patch \
        file://add-loongarch64-support-for-libmetal.patch \
"
