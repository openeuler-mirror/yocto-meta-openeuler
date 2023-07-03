PV = "0.1.18"

S = "${WORKDIR}/${BP}"

SRC_URI = " \
    https://github.com/rpm-software-management/libcomps/archive/refs/tags/${PV}.tar.gz \
    "

# patches from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://0002-Do-not-set-PYTHON_INSTALL_DIR-by-running-python.patch \
           "

SRC_URI[sha256sum] = "02f8aa83dfd19beb7ce250b39818017a6eda7c3984caf8efbd2fc0c70d97bc9a"
