include less-warning.inc

OPENEULER_LOCAL_NAME = "navigation2"

SRC_URI:append = " \
        file://${OPENEULER_LOCAL_NAME}/ros-humble-nav2-constrained-smoother-1.1.9-fix-gcc12-compile-error.patch \
        "
