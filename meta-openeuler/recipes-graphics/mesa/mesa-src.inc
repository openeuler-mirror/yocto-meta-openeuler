OPENEULER_REPO_NAME = "mesa"
OPENEULER_SRC_URI_REMOVE = "http git"

PV = "23.1.3"

SRC_URI:prepend = "file://mesa-${PV}.tar.xz \
           file://backport-fix-build-err-on-arm.patch \
           file://0001-evergreen-big-endian.patch \
           file://llvmpipe-add-an-implementation-with-llvm-orcjit.patch \
           file://llvmpipe-add-riscv-support-in-orcjit.patch \
           file://llvmpipe-make-unnamed-global-have-internal-linkage.patch \
           "
