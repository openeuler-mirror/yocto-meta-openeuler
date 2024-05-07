SUMMARY = "Qt5 Hello World Test Application"
DESCRIPTION = "This application is used to test GUI rendering \
in a simple QWindow, plus displaying message box."
HOMEPAGE = "https://github.com/enjoysoftware/helloworld-gui"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=86da1ce4d01bf33d04fb4d4b88fefe03"

DEPENDS = "qtbase qttools-native"

# Depends on gles2 enabled and that's not default configuration
EXCLUDE_FROM_WORLD = "1"

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI = "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz"

S = "${WORKDIR}/${BP}"

inherit qmake5

# fix error: xxx/recipe-sysroot/usr/bin/lrelease: No such file or directory
do_configure:append() {
    # Find native tools
    if [ -e ${B}/app/Makefile ]; then
        sed -i 's:${STAGING_BINDIR}/lrelease:${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}/lrelease:g' ${B}/app/Makefile
        sed -i 's:${STAGING_BINDIR}/lupdate:${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}/lupdate:g' ${B}/app/Makefile
    fi
}

FILES:${PN} += "/usr/local/*"

RDEPENDS:${PN} += " \
    liberation-fonts \
    "