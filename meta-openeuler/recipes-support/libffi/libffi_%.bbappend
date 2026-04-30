# the main bb file: yocto-poky/meta/recipes-support/libffi/libffi_3.4.4.bb

SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://backport-Fix-signed-vs-unsigned-comparison.patch \
        file://fix-AARCH64EB-support.patch \
"

LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

ASSUME_PROVIDE_PKGS = "libffi"
