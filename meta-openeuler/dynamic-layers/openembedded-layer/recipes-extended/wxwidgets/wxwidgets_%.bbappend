# openeuler version is too old
OPENEULER_SRC_URI_REMOVE = "git"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "3.1.5"

# upstream src and patches
SRC_URI += " file://${OPENEULER_LOCAL_NAME}/${BPN}/wxWidgets-${PV}.tar.gz \
           "

SRC_URI[sha256sum] = "b40d84a3508ebc8ba41bac48448b5932151e1d6f44fdec2460d26bae762140f8"
