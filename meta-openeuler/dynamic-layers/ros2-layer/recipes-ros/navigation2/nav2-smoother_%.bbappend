include less-warning.inc

OPENEULER_LOCAL_NAME = "navigation2"

SRC_URI:append = " \
        file://ros-humble-nav2-smoother-1.1.9-fix-gcc12-error.patch \
        "
