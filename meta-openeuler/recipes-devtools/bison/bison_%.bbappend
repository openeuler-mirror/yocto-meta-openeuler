
PV = "3.8.2"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464"

SRC_URI[sha256sum] = "9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2"

SRC_URI = "file://${BP}.tar.xz \
           file://backport-tests-make-it-easier-to-spot-failures.patch \
           file://backport-fix-syntax-error-on-SymbolKind.toString-method.patch \
           file://backport-fix-interface-syntax-error.patch \
           file://backport-CVE-2026-56389-html-use-xsltproc-from-PATH.patch \
           file://backport-CVE-2026-56390-bison-tighten-up-output-file-names.patch \
           "
