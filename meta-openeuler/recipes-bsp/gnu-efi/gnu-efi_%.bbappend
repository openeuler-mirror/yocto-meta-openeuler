# main bbfile: yocto-poky/meta/recipes-bsp/gnu-efi/gnu-efi_3.0.12.bb

PV = "3.0.8"

# remove tar.gz files and code patches from poky
SRC_URI:remove = " \
        ${SOURCEFORGE_MIRROR}/${BPN}/files/${BP}.tar.bz2 \
"

SRC_URI =+ "file://gnu-efi-${PV}.tar.bz2 "
