require qt5-src.inc

FILESEXTRAPATHS:append := "${THISDIR}/qtwebengine/:"

SRC_URI:remove = " file://${BPN}-everywhere-opensource-src-${PV}.tar.xz "

# remove: riscv64 conflict patches with meta-qt5 patches
#    riscv-v8.patch 
#    riscv-qt5-qtwebengine.patch 
#    qtwebengine-ffmpeg5.patch 

# force-to-build-dir-path.patch fix:
# ERROR Can't get the real build dir path.
# I could not get the real path of xxx
SRC_URI:prepend = " \
    file://qtwebengine-everywhere-src-${PV}-clean.tar.xz \
    file://qtwebengine-opensource-src-5.12.4-fix-extractcflag.patch \
    file://qtwebengine-opensource-src-5.9.0-no-neon.patch \
    file://qtwebengine-SIOCGSTAMP.patch \
    file://qtwebengine-5.15.0-QT_DEPRECATED_VERSION.patch \
    file://chromium-angle-nullptr.patch \
    file://chromium-hunspell-nullptr.patch \
    file://qtwebengine-everywhere-5.15.8-libpipewire-0.3.patch \
    file://qtwebengine-everywhere-src-5.11.3-aarch64-new-stat.patch \
    file://qtwebengine-everywhere-src-5.15.5-TRUE.patch \
    file://qtwebengine-skia-missing-includes.patch \
    file://qtwebengine-5.15-Backport-of-16k-page-support-on-aarch64.patch \
    file://qtwebengine-support-clang-compile.patch \
    file://CVE-2023-6112.patch \
    file://qtwebengine-icu-74.patch \
    file://Backport-ffmpeg-avcodec-x86-mathops-clip-constants-used-with-.patch \
    file://disable-catapult.patch \
    file://python3.patch \
    file://chromium-python3.patch \
    file://fix-build-tools-to-run-with-python3.11.patch \
    file://fix-qt5-qtwebengine-build-with-clang-17.patch \
    file://force-to-build-dir-path.patch \
"

# this patch same as qtwebengine-everywhere-src-5.15.5-TRUE.patch
SRC_URI:remove = " \
    file://chromium/0011-chromium-Remove-TRUE-to-prep-landing-of-icu68.patch;patchdir=src/3rdparty \
"

# fix header found ERROR when compile
do_configure:append() {
    mkdir -p ${S}/include/QtPdf/private
    cp -f ${S}/include/QtPdf/5.15.10/QtPdf/private/* ${S}/include/QtPdf/private
    sed -i 's#\.\./\.\./\.\./\.\./\.\./#\.\./\.\./#g' ${S}/include/QtPdf/private/*

    mkdir -p ${S}/include/QtWebEngineCore/private
    cp -f ${S}/include/QtWebEngineCore/5.15.10/QtWebEngineCore/private/* ${S}/include/QtWebEngineCore/private
    sed -i 's#\.\./\.\./\.\./\.\./\.\./#\.\./\.\./#g' ${S}/include/QtWebEngineCore/private/*

    mkdir -p ${S}/include/QtWebEngine/private
    cp -f ${S}/include/QtWebEngine/5.15.10/QtWebEngine/private/*  ${S}/include/QtWebEngine/private
    sed -i 's#\.\./\.\./\.\./\.\./\.\./#\.\./\.\./#g' ${S}/include/QtWebEngine/private/*
}
