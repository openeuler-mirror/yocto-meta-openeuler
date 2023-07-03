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
