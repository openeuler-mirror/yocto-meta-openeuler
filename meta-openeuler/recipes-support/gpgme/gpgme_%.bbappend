# main bbfile: yocto-poky/meta/recipes-support/gpgme/gpgme_1.17.1.bb

PV = "1.21.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# delete conflict patches of openeuler and poky
# openeuler has add 0004 patch, not use it from poky
SRC_URI:remove = " \
        file://0007-python-Add-variables-to-tests.patch \
        file://0004-python-import.patch \
        "

SRC_URI:prepend = "\ 
        file://${BP}.tar.bz2 \
        file://0001-don-t-add-extra-libraries-for-linking.patch \
        file://gpgme-1.3.2-largefile.patch \
        file://0001-fix-stupid-ax_python_devel.patch \
        file://backport-0002-setup_py_extra_opts.patch \
        file://0001-posix-io.c-Use-off_t-instead-of-off64_t.patch \
        file://0001-autogen.sh-remove-unknown-in-version.patch \
        "

EXTRA_OECONF:remove = "--disable-lang-python-test"

PYTHON_DEPS = "${@bb.utils.contains('LANGUAGES', 'python', 'swig-native', '', d)}"

DEPENDS = "libgpg-error libassuan ${PYTHON_DEPS}"

PYTHON_INHERIT = "${@bb.utils.contains('LANGUAGES', 'python', 'setuptools3-base', '', d)}"

inherit autotools texinfo binconfig-disabled pkgconfig ${PYTHON_INHERIT} python3native multilib_header

CACHED_CONFIGUREVARS:libc-musl = "ac_cv_sys_file_offset_bits=no"
