# bbfile: yocto-meta-openembedded/meta-oe/recipes-extended/wxwidgets/wxwidgets_3.1.5.bb
PV = "3.2.11"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# upstream src and patches
# file://wxGTK3-3.1.6-abicheck.patch
# file://add-pie-compile-option.patch

# the patch had fixed in the version
# file://0001-locale-Avoid-using-glibc-specific-defines-on-musl.patch

# patch set overlaid from the meta-oe master wxwidgets_3.2.11 recipe
# (rebased for 3.2.11; the old 3.2.2-era patches no longer apply)
SRC_URI = " \
        file://wxWidgets-${PV}.tar.bz2 \
        file://0001-wx-config.in-Disable-cross-magic-it-does-not-work-fo.patch \
        file://0002-fix-libdir-for-multilib.patch \
        file://0004-don-not-append-system-name-to-lib-name.patch \
        file://0006-Fix-locale-on-musl.patch \
        file://0007-Set-HAVE_LARGEFILE_SUPPORT-to-1-explicitly.patch \
"

S = "${WORKDIR}/wxWidgets-${PV}"

SRC_URI[sha256sum] = "6a129015bce2e914e4bf61ec4411854ad962801d47e92f2eb8340adb6a90af08"

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
