# main bbfile: yocto-poky/meta/recipes-graphics/fontconfig/fontconfig_2.13.1.bb

# version in src-openEuler
PV = "2.15.0"

# license files changed, update LIC_FILES_CHKSUM value
LICENSE = "MIT & MIT & PD"
LIC_FILES_CHKSUM = "file://COPYING;md5=00252fd272bf2e722925613ad74cb6c7 \
                    file://src/fcfreetype.c;endline=45;md5=ef8702fbf3dc506715be8a9d69cb0252 \
                    "

# fontconfig-2.13.94-sw.patch is for arch sw, no need current
SRC_URI:prepend = "file://${BP}.tar.xz \
           file://backport-fontconfig-disable-network-required-test.patch \
"

SRC_URI[md5sum] = "ab06ff17524de3f1ddd3c97ed8a02f8d"
SRC_URI[sha256sum] = "a5f052cb73fd479ffb7b697980510903b563bbb55b8f7a2b001fcfb94026003c"
