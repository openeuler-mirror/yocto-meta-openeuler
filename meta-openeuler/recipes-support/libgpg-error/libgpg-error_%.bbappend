# version in openEuler
PV = "1.47"

# 0001-Do-not-fail-when-testing-config-scripts.patch applies with fuzz on 1.50

# License update - remove incorrect duplicate entry, 1.47 matches base recipe checksum

# patch directory
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# apply source package in openEuler
SRC_URI:remove = "file://pkgconfig.patch \
"

SRC_URI:remove = "${GNUPG_MIRROR}/libgpg-error/libgpg-error-${PV}.tar.bz2"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://libgpg-error-1.29-multilib.patch \
"

SRC_URI[sha256sum] = "685d4bd9d05576c4fc7f0870903dfdfbe41f2dd6a12e76fd8bd1717278f6b365"

ASSUME_PROVIDE_PKGS = "libgpg-error"
