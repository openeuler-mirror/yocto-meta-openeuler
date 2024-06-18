# main bbfile: meta-oe/recipes-extended/libpwquality/libpwquality_1.4.4.bb
# change install dir: ${base_libdir}(meta-openeuler) -> ${libdir}(meta-oe)

SRC_URI_remove = "file://add-missing-python-include-dir-for-cross.patch \
"

OPENEULER_SRC_URI_REMOVE = "https git"

PV = "1.4.5"

SRC_URI =+ " \
    file://libpwquality-${PV}.tar.bz2 \
    file://modify-pwquality_conf.patch \
    file://fix-password-similarity.patch \
    file://fix-doc-about-difok.patch \
"

# do not enable python bindings, as well as not use gettext to translate
DEPENDS_remove = "virtual/gettext ${PYTHON_PN}-native ${PYTHON_PN}"
RDEPENDS_${PN}_remove = "${@['', '${PYTHON_PN}-core']['${CLASSOVERRIDE}' == 'class-target']}"

EXTRA_OECONF_remove = "--with-python-rev=${PYTHON_BASEVERSION} \
                 --with-python-binary=${STAGING_BINDIR_NATIVE}/${PYTHON_PN}-native/${PYTHON_PN} \
                 --with-pythonsitedir=${PYTHON_SITEPACKAGES_DIR} \
"
EXTRA_OECONF += "--enable-python-bindings=no \
"
