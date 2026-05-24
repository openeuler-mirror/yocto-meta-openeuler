# the main bb file: yocto-poky/meta/recipes-support/libffi/libffi_3.4.4.bb

# SP4 openeuler/libffi has 3.4.4 tarball
PV = "3.4.4"

# Fix LIC_FILES_CHKSUM for 3.4.4 vs base recipe 3.4.6
LIC_FILES_CHKSUM:remove = "file://LICENSE;md5=1db54c9fd307a12218766c3c7f650ca7"
LIC_FILES_CHKSUM:append = " file://LICENSE;md5=32c0d09a0641daf4903e5d61cc8f23a8"

SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://fix-AARCH64EB-support.patch \
"
# backport-Fix-signed-vs-unsigned-comparison.patch already incorporated in libffi 3.4.6

LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

ASSUME_PROVIDE_PKGS = "libffi"
