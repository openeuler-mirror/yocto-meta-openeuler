DESCRIPTION = "Library for password quality checking and generating random passwords"
HOMEPAGE = "https://github.com/libpwquality/libpwquality"
SECTION = "devel/lib"
LICENSE = "GPLv2"

PARALLEL_MAKE = "-j 1"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bd2f1386df813a459a0c34fde676fc2"

SRC_URI = "file://${BP}.tar.bz2 \
           file://modify-pwquality_conf.patch \
           file://fix-password-similarity.patch \
           file://fix-doc-about-difok.patch \
"

DEPENDS = "cracklib"

inherit autotools gettext

export PYTHON_DIR
export BUILD_SYS
export HOST_SYS

EXTRA_OECONF += "--enable-python-bindings=no \
                 --libdir=${base_libdir} \
"

do_install_append() {
	rm  -r ${D}/${base_libdir}/pkgconfig
}

PACKAGECONFIG ??= "pam"
PACKAGECONFIG[pam] = "--enable-pam, --disable-pam, libpam"
FILES_${PN} += "${base_libdir}/security/pam_pwquality.so"
FILES_${PN}-dbg += "${base_libdir}/security/.debug"
FILES_${PN}-staticdev += "${base_libdir}/security/pam_pwquality.a"
FILES_${PN}-dev += "${base_libdir}/security/pam_pwquality.la"
