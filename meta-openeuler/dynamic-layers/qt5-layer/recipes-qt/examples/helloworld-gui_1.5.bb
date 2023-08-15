SUMMARY = "Qt5 Hello World Test Application"
DESCRIPTION = "This application is used to test GUI rendering \
in a simple QWindow, plus displaying message box."
HOMEPAGE = "https://github.com/enjoysoftware/helloworld-gui"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=86da1ce4d01bf33d04fb4d4b88fefe03"

DEPENDS = "qtbase qttools-native"

# Depends on gles2 enabled and that's not default configuration
EXCLUDE_FROM_WORLD = "1"

SRC_URI = "file://${BP}.tar.gz"

S = "${WORKDIR}/${BP}"

inherit qmake5

# fix error: xxx/recipe-sysroot/usr/bin/lrelease: No such file or directory
do_prepare_lrelease() {
    ln -s ${STAGING_BINDIR_NATIVE}/lrelease ${STAGING_BINDIR}/lrelease
}

do_prepare_recipe_sysroot[postfuncs] += "do_prepare_lrelease"

FILES:${PN} += "/usr/local/*"
