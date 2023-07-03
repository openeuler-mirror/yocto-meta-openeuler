# main bbfile: yocto-poky/meta/recipes-support/libunwind/libunwind_1.6.2.bb

# do not apply poky's conflict patch
SRC_URI = "file://${BP}.tar.gz \
    file://0001-fix-byte_order_is_valid-function-logic.patch \
    file://backport-check-namespace.sh-adjust-aarch64-symbols.patch \
    file://backport-tests-run-coredump-unwind-Skip-test-if-no-coredump-h.patch \
"

SRC_URI[md5sum] = "f625b6a98ac1976116c71708a73dc44a"
SRC_URI[sha256sum] = "4a6aec666991fb45d0889c44aede8ad6eb108071c3554fcdff671f9c94794976"
