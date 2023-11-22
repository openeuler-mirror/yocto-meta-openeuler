# main bbfile: yocto-poky/meta/recipes-kernel/kmod/kmod_git.bb

# kmod version in openEuler
PV = "29"

# Use the source packages from openEuler
SRC_URI_remove = "git://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git \
        git://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git;branch=master \
        "
SRC_URI_prepend = "file://${BP}.tar.xz \
        file://0001-libkmod-module-check-new_from_name-return-value-in-g.patch \
        file://0002-Module-replace-the-module-with-new-module.patch \
        file://0003-Module-suspend-the-module-by-rmmod-r-option.patch \
        file://0004-don-t-check-module-s-refcnt-when-rmmod-with-r.patch \
        file://backport-libkmod-Support-SM3-hash-algorithm.patch \
        file://backport-libkmod-do-not-crash-on-unknown-signature-algorithm.patch \
        file://backport-libkmod-error-out-on-unknown-hash-algorithm.patch \
        file://backport-libkmod-Set-builtin-to-no-when-module-is-created-fro.patch \
        file://backport-modprobe-fix-the-NULL-termination-of-new_argv.patch \
        file://backport-shared-avoid-passing-NULL-0-array-to-bsearch.patch \
        file://backport-libkmod-fix-possible-out-of-bounds-memory-access.patch \
        "

SRC_URI[md5sum] = "e81e63acd80697d001c8d85c1acb38a0"
SRC_URI[sha256sum] = "0b80eea7aa184ac6fd20cafa2a1fdf290ffecc70869a797079e2cc5c6225a52a"

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"
