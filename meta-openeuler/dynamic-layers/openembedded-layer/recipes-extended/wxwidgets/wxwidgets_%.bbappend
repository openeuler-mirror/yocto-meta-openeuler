# bbfile: yocto-meta-openembedded/meta-oe/recipes-extended/wxwidgets/wxwidgets_3.1.5.bb
PV = "3.2.2.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# upstream src and patches
# file://wxGTK3-3.1.6-abicheck.patch
# file://add-pie-compile-option.patch

# the patch had fixed in the version
# file://0001-locale-Avoid-using-glibc-specific-defines-on-musl.patch

SRC_URI = " \
        file://wxWidgets-${PV}.tar.bz2 \
        file://0001-wx-config.in-Disable-cross-magic-it-does-not-work-fo.patch \
        file://fix-libdir-for-multilib.patch \
        file://create-links-with-relative-path.patch \
        file://not-append-system-name-to-lib-name.patch \
        file://wx-config-fix-libdir-for-multilib.patch \
        file://musl-locale-l.patch \
        file://0001-Set-HAVE_LARGEFILE_SUPPORT-to-1-explicitly.patch \
"

S = "${WORKDIR}/wxWidgets-${PV}"

SRC_URI[sha256sum] = "dffcb6be71296fff4b7f8840eb1b510178f57aa2eb236b20da41182009242c02"

EXTRA_OECMAKE:remove = "-DwxPLATFORM_LIB_DIR=${@d.getVar('baselib').replace('lib', '')}"

EXTRA_OECMAKE:remove:libc-musl = " \
    -DHAVE_LOCALE_T=OFF \
"
PACKAGECONFIG[gtk] = "-DwxBUILD_TOOLKIT=gtk3 -DwxUSE_GUI=ON -DwxUSE_PRIVATE_FONTS=ON,,gtk+3,,,no_gui qt"
PACKAGECONFIG[webkit] = "-DwxUSE_WEBVIEW_WEBKIT=ON,-DwxUSE_WEBVIEW_WEBKIT=OFF,webkitgtk3,,,no_gui"

# Support LFS unconditionally
CXXFLAGS += "-D_FILE_OFFSET_BITS=64"

FILES:${PN} += " \
    ${libdir}/cmake/ \
    "

FILES:${PN}-dev += " \
    ${libdir}/libwx_* \
    "

INSANE_SKIP:${PN}-bin += "dev-deps"

