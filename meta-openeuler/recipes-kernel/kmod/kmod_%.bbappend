# main bbfile: yocto-poky/meta/recipes-kernel/kmod/kmod_git.bb

# kmod version in openEuler
PV = "29"

# Use the source packages from openEuler
SRC_URI_remove = "git://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git"
SRC_URI_prepend = "file://kmod/${BP}.tar.xz "
SRC_URI += "file://kmod/0001-libkmod-module-check-new_from_name-return-value-in-g.patch \
            file://kmod/0002-Module-replace-the-module-with-new-module.patch \
            file://kmod/0003-Module-suspend-the-module-by-rmmod-r-option.patch \
            file://kmod/0004-don-t-check-module-s-refcnt-when-rmmod-with-r.patch \
            "

SRC_URI[md5sum] = "e81e63acd80697d001c8d85c1acb38a0"
SRC_URI[sha256sum] = "0b80eea7aa184ac6fd20cafa2a1fdf290ffecc70869a797079e2cc5c6225a52a"

S = "${WORKDIR}/${BP}"
