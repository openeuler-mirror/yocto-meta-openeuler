OPENEULER_LOCAL_NAME = "mesa"

PV = "23.3.1"

SRC_URI:prepend = "file://mesa-${PV}.tar.xz \
            file://backport-fix-build-err-on-arm.patch \
            file://0001-changed_by_upstream_26018_orcjit_patch.patch \
            file://0001-llvmpipe-add-loongarch64-basic-support.patch \
            file://0002-llvmpipe-support-loongarch64-orcjit.patch \
           "
