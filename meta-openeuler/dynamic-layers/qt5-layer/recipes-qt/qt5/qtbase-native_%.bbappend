require qt5-src.inc

# License update
LIC_FILES_CHKSUM:remove = "file://LICENSE.QT-LICENSE-AGREEMENT;md5=c8b6dd132d52c6e5a545df07a4e3e283"
LIC_FILES_CHKSUM:prepend = "file://LICENSE.QT-LICENSE-AGREEMENT;md5=38de3b110ade3b6ee2f0b6a95ab16f1a \
"

# not need in version 5.15.10
SRC_URI:remove = "file://0008-Replace-pthread_yield-with-sched_yield.patch \
file://0010-linux-clang-Invert-conditional-for-defining-QT_SOCKL.patch \
"

SRC_URI:prepend = "file://qtbase-everywhere-src-5.15.6-private_api_warning.patch \
           file://qtbase-opensource-src-5.8.0-QT_VERSION_CHECK.patch \
           file://qtbase-opensource-src-5.7.1-moc_macros.patch \
           file://qtbase-everywhere-src-5.12.1-qt5gui_cmake_isystem_includes.patch \
           file://qtbase-qmake_LFLAGS.patch \
           file://qtbase-everywhere-src-5.14.2-no_relocatable.patch \
           file://qtbase-everywhere-src-5.15.2-libglvnd.patch \
           file://qt5-qtbase-cxxflag.patch \
           file://qt5-qtbase-5.12.1-firebird.patch \
           file://qtbase-opensource-src-5.9.0-mysql.patch \
           file://qtbase-use-wayland-on-gnome.patch \
           file://qt5-qtbase-gcc11.patch \
           file://kde-5.15-rollup-20230613.patch.gz \
           file://qtbase-5.15.10-fix-missing-qtsan-include.patch \
           file://qtbase-QTBUG-111994.patch \
           file://qtbase-QTBUG-112136.patch \
           file://qtbase-QTBUG-103393.patch \
           file://qt5-qtbase-Add-sw64-architecture.patch \
           file://add-loongarch64-support.patch \
           file://Fix-lupdate-command-error-on-loongarch64.patch \
           file://CVE-2023-37369.patch \
           "
