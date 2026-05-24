# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

# gzip version in openEuler
PV = "1.12"

SRC_URI:prepend = "file://${BP}.tar.xz \
           file://backport-gzip-detect-invalid-input.patch \
           file://backport-gzip-test-invalid-input-bug.patch \
           file://fix-verbose-disable.patch \
           "

SRC_URI:remove = " \
           file://backport-gzip-detect-invalid-input.patch \
           file://backport-gzip-test-invalid-input-bug.patch \
           file://wrong-path-fix.patch \
"


LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://gzip.h;beginline=8;endline=20;md5=6e47caaa630e0c8bf9f1bc8d94a8ed0e"
SRC_URI[sha256sum] = "ce5e03e519f637e1f814011ace35c4f87b33c0bbabeec35baf5fbd3479e91956"

ASSUME_PROVIDE_PKGS = "gzip"
