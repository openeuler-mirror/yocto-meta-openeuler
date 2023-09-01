PV = "4.0.2"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# openeuler add patches to change pcre to pcre2, no apply
SRC_URI = "${SOURCEFORGE_MIRROR}/${BPN}/${BPN}-${PV}.tar.gz"
SRC_URI += "file://0001-Use-proc-self-exe-for-swig-swiglib-on-non-Win32-plat.patch \
            file://determinism.patch \
            file://0001-configure-use-pkg-config-for-pcre-detection.patch \
            file://Backport-php-8-support-from-upstream.patch \
            file://0001-Ruby-Fix-deprecation-warnings-with-Ruby-3.x.patch \
            file://0001-gcc-12-warning-fix-in-test-case.patch \
           "

SRC_URI[md5sum] = "7c3e46cb5af2b469722cafa0d91e127b"
SRC_URI[sha256sum] = "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
