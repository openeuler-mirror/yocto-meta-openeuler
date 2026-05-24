
PV = "1.15.2"

# from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:prepend = " file://${BP}.tar.gz \
           "

# poky patches 0001/0002/0004 target librepo 1.17.0, not compatible with 1.15.2
SRC_URI:remove = " \
    file://0001-gpg_gpgme.c-fix-build-errors-with-older-gcc.patch \
    file://0002-Do-not-try-to-obtain-PYTHON_INSTALL_DIR-by-running-p.patch \
    file://0004-Set-gpgme-variables-with-pkg-config-not-with-cmake-m.patch \
"

# cmake FindGpgme.cmake uses poisoned gpgme-config and finds no libs;
# replace FIND_PACKAGE(Gpgme) with pkg-config so libgpgme.so is properly linked
do_configure:prepend() {
    sed -i 's|FIND_PACKAGE(Gpgme REQUIRED)|PKG_CHECK_MODULES(GPGME gpgme REQUIRED)\nset(GPGME_VANILLA_LIBRARIES ${GPGME_LIBRARIES})|' ${S}/CMakeLists.txt
}

S = "${WORKDIR}/${BP}"
