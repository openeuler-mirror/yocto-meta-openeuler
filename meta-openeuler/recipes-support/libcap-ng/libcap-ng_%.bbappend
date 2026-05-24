# main bb: yocto-poky/meta/recipes-support/libcap-ng/libcap-ng_0.8.2.bb

PV = "0.8.3"

# determinism.patch and other patches no longer needed for 0.9
SRC_URI:remove = "file://determinism.patch \
        file://0001-Fix-python-path-when-invoking-py-compile-54.patch \
        "

SRC_URI:append = " \
        file://libcap-ng-${PV}.tar.gz \
        file://backport-Fix-the-syntax-error-in-cap-ng-c-50.patch \
        file://backport-Make-Python-test-script-compatible-with-Python2-and-Python3.patch \
        "

S = "${WORKDIR}/${BPN}-${PV}"
# libcap-ng 0.8.3 does not support out-of-tree builds
B = "${S}"

# The openEuler v0.9 tarball configure script was generated without pkg.m4,
# causing 'syntax error near PKG_CHECK_MODULES'. Regenerate with autoreconf.
EXTRA_AUTORECONF = "-Wcross"
do_configure:prepend() {
    cd ${S}
    # OpenEuler v0.9 tarball is missing automake required files
    touch NEWS AUTHORS ChangeLog README 2>/dev/null || true
    autoreconf -fiv
}

ASSUME_PROVIDE_PKGS = "libcap-ng"
