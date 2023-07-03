# main bbfile: yocto-poky/meta/recipes-graphics/jpeg/libjpeg-turbo_2.1.5.1.bb

# version in openEuler
PV = "2.1.1"

# new lic checksum
LIC_FILES_CHKSUM = "file://cdjpeg.h;endline=13;md5=8a61af33cc1c681cd5cc297150bbb5bd \
                    file://jpeglib.h;endline=16;md5=52b5eaade8d5b6a452a7693dfe52c084 \
                    file://djpeg.c;endline=11;md5=b61f01ad6aff437b34d1f9e8004280a4 \
"

SRC_URI:remove = " \
    ${SOURCEFORGE_MIRROR}/${BPN}/${BPN}-${PV}.tar.gz \
"

SRC_URI:append = " \
    file://libjpeg-turbo-${PV}.tar.gz \
"

# new check value
SRC_URI[md5sum] = "cf16866976ab31cd6fc478eac8c2c54e"
SRC_URI[sha256sum] = "b76aaedefb71ba882cbad4e9275b30c2ae493e3195be0a099425b5c6b99bd510"
