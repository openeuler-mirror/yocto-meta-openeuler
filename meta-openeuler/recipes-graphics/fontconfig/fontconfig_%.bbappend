# main bbfile: yocto-poky/meta/recipes-graphics/fontconfig/fontconfig_2.13.1.bb

# version in src-openEuler
PV = "2.13.94"

# license files changed, update LIC_FILES_CHKSUM value
LICENSE = "MIT & MIT & PD"
LIC_FILES_CHKSUM = "file://COPYING;md5=00252fd272bf2e722925613ad74cb6c7 \
                    file://src/fcfreetype.c;endline=45;md5=ce976b310a013a6ace6b60afa71851c1 \
                    "

SRC_URI_remove = "http://fontconfig.org/release/fontconfig-${PV}.tar.gz \
"

# fontconfig-2.13.94-sw.patch is for arch sw, no need current
SRC_URI_prepend = "file://fontconfig-${PV}.tar.xz \
           file://backport-fontconfig-disable-network-required-test.patch \
           file://backport-Report-more-detailed-logs-instead-of-assertion.patch \
"
