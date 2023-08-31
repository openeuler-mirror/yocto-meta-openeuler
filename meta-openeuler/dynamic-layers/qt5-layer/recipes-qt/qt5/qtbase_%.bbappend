# main bbfile: meta-qt5/recipes-qt/qt5/qtbase_git.bb
require qt5-src.inc

SRC_URI:prepend = "file://tell-the-truth-about-private-api.patch \
           file://qtbase-opensource-src-5.8.0-QT_VERSION_CHECK.patch \
           file://qtbase-opensource-src-5.7.1-moc_macros.patch \
           file://qtbase-everywhere-src-5.12.1-qt5gui_cmake_isystem_includes.patch \
           file://qtbase-qmake_LFLAGS.patch \
           file://qtbase-everywhere-src-5.14.2-no_relocatable.patch \
           file://qt5-qtbase-cxxflag.patch \
           file://qt5-qtbase-5.12.1-firebird.patch \
           file://qtbase-opensource-src-5.9.0-mysql.patch \
           file://qtbase-everywhere-src-5.11.1-python3.patch \
           file://qtbase-use-wayland-on-gnome.patch \
           file://qt5-qtbase-gcc11.patch \
           file://qtbase-QTBUG-90395.patch \
           file://qtbase-QTBUG-89977.patch \
           file://qtbase-QTBUG-91909.patch \
           file://0001-modify-kwin_5.18-complier-error.patch \
           file://CVE-2021-38593.patch \
           file://CVE-2022-25255.patch \
           "

# openeuler configuration: 
# ref: meta-raspberrypi/dynamic-layers/qt5-layer/recipes-qt/qt5/qtbase_%.bbappend
PACKAGECONFIG_GL = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'gl', \
                        bb.utils.contains('DISTRO_FEATURES',     'opengl', 'eglfs gles2', \
                                                                       '', d), d)}"

PACKAGECONFIG_GL:append = " kms gbm"
PACKAGECONFIG_FONTS = "fontconfig"
PACKAGECONFIG:append = " libinput examples tslib xkbcommon"

OE_QTBASE_EGLFS_DEVICE_INTEGRATION = ""

do_configure:prepend() {
    # Add the appropriate EGLFS_DEVICE_INTEGRATION
    if [ "${@d.getVar('OE_QTBASE_EGLFS_DEVICE_INTEGRATION')}" != "" ]; then
        echo "EGLFS_DEVICE_INTEGRATION = ${OE_QTBASE_EGLFS_DEVICE_INTEGRATION}" >> ${S}/mkspecs/oe-device-extra.pri
    fi
}
