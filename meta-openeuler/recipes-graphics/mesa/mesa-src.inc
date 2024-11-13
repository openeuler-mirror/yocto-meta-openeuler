OPENEULER_LOCAL_NAME = "mesa"

PV = "24.0.3"

SRC_URI:remove = " \
           file://0001-meson-misdetects-64bit-atomics-on-mips-clang.patch \
           "

SRC_URI:prepend = "file://mesa-${PV}.tar.xz \
           file://backport-fix-build-err-on-arm.patch \
           "
