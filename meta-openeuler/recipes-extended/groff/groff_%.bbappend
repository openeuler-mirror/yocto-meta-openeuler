# source bb file: yocto-poky/meta/recipes-extended/groff/groff_1.22.4.bb
PV = "1.23.0"

# the OPENEULER_SRC_URI_REMOVE will remove the original URL of the tarball
#  which is from upstream community if the software package exists in manifest.yaml.
# Thus, it is necessary to add the new file path of the tarball to SRC_URI
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    "

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# patches from poky for version 1.23.0
SRC_URI:append = " \
    file://0001-build-Fix-Savannah-64681-webpage.ps-deps.patch \
    file://0001-build-meintro_fr.ps-depends-on-tbl.patch \
"

# patches from openEuler
SRC_URI:append = " \
    file://backport-nroff-map-CW-to-R.patch \
"

# patches not needed for version 1.23.0
SRC_URI:remove = " \
    file://0001-replace-perl-w-with-use-warnings.patch \
    file://0001-support-musl.patch \
    file://0001-Include-config.h.patch \
    file://0001-Make-manpages-mulitlib-identical.patch \
"

DEPENDS += "groff-native"

MULTILIB_SCRIPTS:remove = "${PN}:${bindir}/groffer"

EXTRA_OECONF:remove = "--without-doc"

EXTRA_OECONF:append = " \
    --with-urw-fonts-dir=/completely/bogus/dir/ \
"

EXTRA_OEMAKE:class-target = "GROFFBIN=groff GROFF_BIN_PATH=${STAGING_BINDIR_NATIVE}"

do_install:append() {
        # strip hosttool path out of generated files
        sed -i -e 's:${HOSTTOOLS_DIR}/::g' ${D}${docdir}/${BP}/examples/hdtbl/*.roff
}
