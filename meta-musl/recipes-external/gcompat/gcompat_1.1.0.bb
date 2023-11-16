SUMMARY = "a library which provides glibc-compatible APIs for use on musl libc systems"
HOMEPAGE = "https://git.adelielinux.org/adelie/gcompat"
LICENSE = "NCSA"
LIC_FILES_CHKSUM = "file://LICENSE;md5=802b1aed7330d90086be4de63a3188e3"
SECTION = "libs"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "1.1.0"
SRC_URI = "file://${OPENEULER_LOCAL_NAME}/${BPN}/gcompat-${PV}.tar.gz \
           file://gcompat-modify-makefile.patch \
           file://libgcompat_musl.patch \
          "

SRC_URI[sha256sum] = "82e56d2ecda3f11a93efe61001394a6e5db39c91127d0812d7ad5b0bda558010"

do_configure() {
        :
}

do_compile() {
        oe_runmake
}

do_install() {
   oe_runmake install DESTDIR=${D}
   install -d ${D}${includedir}
   install -m 644 ${S}/libgcompat/*.h  ${D}${includedir}
}
