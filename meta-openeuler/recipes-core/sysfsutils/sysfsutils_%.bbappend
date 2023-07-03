# version in openEuler
PV = "2.1.1"

# remove patches that can't apply in poky
SRC_URI:remove = "${SOURCEFORGE_MIRROR}/linux-diag/sysfsutils-${PV}.tar.gz \
                  file://sysfsutils-2.0.0-class-dup.patch \
                  file://obsolete_automake_macros.patch \
                  file://separatebuild.patch \
"

SRC_URI:prepend = "file://sysfsutils/v${PV}.tar.gz \
"

SRC_URI += "file://0001-lib-Fixed-a-memory-leak-in-lib-sysfs_driver.patch \
"

# checksum changed in this version
LIC_FILES_CHKSUM = "file://COPYING;md5=dcc19fa9307a50017fca61423a7d9754 \
                    file://cmd/GPL;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://lib/LGPL;md5=4fbd65380cdd255951079008b364516c"

SRC_URI[md5sum] = "537c110be7244905997262854505c30f"
SRC_URI[sha256sum] = "f7f669d27c997d3eb3f3e014b4c0aa1aa4d07ce4d6f9e41fa835240f2bf38810"
