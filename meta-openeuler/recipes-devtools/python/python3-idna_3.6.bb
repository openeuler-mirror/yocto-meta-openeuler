SUMMARY = "Internationalised Domain Names in Applications"
HOMEPAGE = "https://github.com/kjd/idna"
LICENSE = "BSD-3-Clause & Python-2.0 & Unicode-TOU"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=dbec47b98e1469f6a104c82ff9698cee"
PV = "3.6"
SRC_URI[md5sum] = "70f4beef4feb196ac64b75a93271f53c"
SRC_URI[sha256sum] = "9ecdbbd083b06798ae1e86adcbfe8ab1479cf864e4ee30fe4e46a003d12491ca"

inherit pypi python_flit_core
require pypi-src-openeuler.inc

RDEPENDS:${PN}:class-target = "\
    python3-codecs \
"

BBCLASSEXTEND = "native nativesdk"
