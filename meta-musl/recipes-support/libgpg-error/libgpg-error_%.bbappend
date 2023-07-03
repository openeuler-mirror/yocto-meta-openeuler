# the main bb file: yocto-poky/meta/recipes-support/libgpg-error/libgpg-error_1.44.bb

PV = "1.46"

# patch directary
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:remove = " \
        ${GNUPG_MIRROR}/libgpg-error/libgpg-error-${PV}.tar.bz2 \
"

# add patch to support musl
SRC_URI:append = " \
        file://libgpg-error-${PV}.tar.gz \
        file://libgpg-error-1.29-multilib.patch \
        file://libgpg-error-musl.patch \
"

SRC_URI[sha256sum] = "5b724411231f40cb0454250379a9a659e1dda69c161ba8d69f89c7a39a847b7e"
