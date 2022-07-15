PV = "1.4.19"

SRC_URI = " \
    ${GNU_MIRROR}/m4/m4-${PV}.tar.xz \
    file://0001-Delete-test-execute_sh.patch \
"
xSRC_URI = "${GNU_MIRROR}/m4/m4-${PV}.tar.gz \
           file://ac_config_links.patch \
           file://m4-1.4.18-glibc-change-work-around.patch \
           "

SRC_URI[md5sum] = "0d90823e1426f1da2fd872df0311298d"
SRC_URI[sha256sum] = "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464\
                    file://examples/COPYING;md5=4031593b2166d6c47cae282d944a7ede"
