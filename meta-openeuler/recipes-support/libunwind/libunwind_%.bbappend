# main bbfile: yocto-poky/meta/recipes-support/libunwind/libunwind_1.6.2.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "1.6.2"

SRC_URI:prepend = "file://${BP}.tar.gz \
           file://0001-fix-byte_order_is_valid-function-logic.patch \
           file://backport-check-namespace.sh-adjust-aarch64-symbols.patch \
           file://backport-tests-run-coredump-unwind-Skip-test-if-no-coredump-h.patch \
           file://backport-aarch64-unw_step-validates-address-before-calling-dwarf_get.patch \
           file://backport-avoid-calling-printf-because-OE-glibc-2.34-used-mno-.patch \
           file://backport-fix-run-ptrace-mapper-test-case-failed.patch \
           "
