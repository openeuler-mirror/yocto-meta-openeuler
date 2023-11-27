PV = "3.10.9"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:remove = "http://www.python.org/ftp/python/${PV}/Python-${PV}.tar.xz \
"

SRC_URI += "file://Python-3.10.9.tar.xz \
"

# remove conflicting patch
SRC_URI:remove = "file://cve-2023-24329.patch"

SRC_URI:prepend = " file://00001-rpath.patch \
           file://00251-change-user-install-location.patch \
           file://backport-Make-urllib.parse.urlparse-enforce-that-a-scheme-mus.patch \
           file://add-the-sm3-method-for-obtaining-the-salt-value.patch \
           file://fix-CVE-2023-24329.patch \
"

# add sysconfigdata patch with lib64 to path, else will put error that can not found _sysconfigdata module
# the result is libdir in openeuler is /usr/lib64, but in ros is /usr/lib, so if a python package in openeuler
# has a relation with a python package in ros, it can not find openeuler python package in /usr/lib path
SRC_URI:append:class-native = " \
    file://distutils-sysconfig-append-STAGING_LIBDIR-with-lib64-python-sys.patch \
"

# meta-openeuler layer does not need to build python3-native dependency packages,
# but gets them directly from the nativesdk tool
# Find header from nativesdk
CPPFLAGS:append:class-native = " ${@oe.utils.vartrue('OPENEULER_PREBUILT_TOOLS_ENABLE', \
    '-I${OPENEULER_NATIVESDK_SYSROOT}/usr/include \
     -I${OPENEULER_NATIVESDK_SYSROOT}/usr/include/ncursesw \
     -I${OPENEULER_NATIVESDK_SYSROOT}/usr/include/uuid', \
    '', d)} \
"

# Find library from nativesdk
LDFLAGS:append:class-native = " ${@oe.utils.vartrue('OPENEULER_PREBUILT_TOOLS_ENABLE', \
    '-L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib', '', d)}"
