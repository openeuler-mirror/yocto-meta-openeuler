PV = "1.14.5"

S = "${WORKDIR}/${BP}"

SRC_URI = " \
    https://github.com/rpm-software-management/librepo/archive/${PV}/${BPN}-${PV}.tar.gz \
    "

# from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://0002-Do-not-try-to-obtain-PYTHON_INSTALL_DIR-by-running-p.patch \
           file://0004-Set-gpgme-variables-with-pkg-config-not-with-cmake-m.patch \
           "

SRC_URI[sha256sum] = "6fb7dbbcfa48e333633beabf830d75f20b347ae5b9734ffde3164fef8d093391"
