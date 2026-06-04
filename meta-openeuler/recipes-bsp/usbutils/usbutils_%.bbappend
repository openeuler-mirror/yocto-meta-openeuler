# bbfile: yocto-poky/meta/recipes-bsp/usbutils/usbutils_014.bb

PV = "017"

SRC_URI = "file://usbutils-${PV}.tar.xz \
          "
SRC_URI[sha256sum] = "a6a25ffdcf9103e38d7a44732aca17073f4e602b92e4ae55625231a82702e05b"

do_install:append() {
    sed -i 's|-fmacro-prefix-map=[^ ]*||g; s|-fdebug-prefix-map=[^ ]*||g' ${D}${libdir}/pkgconfig/usbutils.pc
}

ASSUME_PROVIDE_PKGS = "usbutils"
