require libmetal.inc

SRC_URI:prepend = " \
        file://libmetal-add-additional-arches.patch \
        file://add-riscv-support.patch \
"
