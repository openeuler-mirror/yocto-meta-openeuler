# openeuler version is too old
OPENEULER_REPO_NAME = "wxGTK3"
OPENEULER_SRC_URI_REMOVE = "git"
PV = "3.1.5"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# upstream src and patches
SRC_URI:append = " file://wxWidgets-${PV}.tar.gz \
           "

SRC_URI[sha256sum] = "b40d84a3508ebc8ba41bac48448b5932151e1d6f44fdec2460d26bae762140f8"
