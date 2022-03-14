SUMMARY = "A stream-oriented XML parser library"
DESCRIPTION = "Expat is an XML parser library written in C. It is a stream-oriented parser in which an application registers handlers for things the parser might find in the XML document (like start tags)"
HOMEPAGE = "http://expat.sourceforge.net/"
SECTION = "libs"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://COPYING;md5=9e2ce3b3c4c0f2670883a23bbd7c37a9"

SRC_URI = "file://expat/expat-${PV}.tar.gz \
           file://expat/backport-CVE-2021-45960.patch \
           file://expat/backport-CVE-2021-46143.patch \
           file://expat/backport-CVE-2022-22822-CVE-2022-22823-CVE-2022-22824-CVE-2022-22825-CVE-2022-22826-CVE-2022-22827.patch \
           file://expat/backport-CVE-2022-23852-lib-Detect-and-prevent-integer-overflow-in-XML_GetBu.patch \
           file://expat/backport-CVE-2022-23852-tests-Cover-integer-overflow-in-XML_GetBuffer-CVE-20.patch \
           file://expat/backport-CVE-2022-23990-lib-Prevent-integer-overflow-in-doProlog-CVE-2022-23.patch \
           file://expat/backport-CVE-2022-25235-lib-Add-missing-validation-of-encoding.patch \
           file://expat/backport-tests-Cover-missing-validation-of-encoding.patch \
           file://expat/backport-CVE-2022-25236-lib-Protect-against-malicious-namespace-declarations.patch \
           file://expat/backport-tests-Cover-CVE-2022-25236.patch \
           file://expat/backport-CVE-2022-25313-Prevent-stack-exhaustion-in-build_model.patch \
           file://expat/backport-CVE-2022-25314-Prevent-integer-overflow-in-copyString.patch \
           file://expat/backport-CVE-2022-25315-Prevent-integer-overflow-in-storeRawNames.patch \
           file://expat/backport-Fix-build_model-regression.patch \
           file://expat/backport-tests-Protect-against-nested-element-declaration-mod.patch \
           file://expat/backport-lib-Fix-harmless-use-of-uninitialized-memory.patch \
           file://expat/backport-lib-Drop-unused-macro-UTF8_GET_NAMING.patch \
           file://expat/backport-lib-Relax-fix-to-CVE-2022-25236-with-regard-to-RFC-3.patch \
           file://expat/backport-tests-Cover-relaxed-fix-to-CVE-2022-25236.patch \
           file://libtool-tag.patch \
	   file://run-ptest \
	  "

SRC_URI[sha256sum] = "2f9b6a580b94577b150a7d5617ad4643a4301a6616ff459307df3e225bcfbf40"

EXTRA_OECMAKE_class-native += "-DEXPAT_BUILD_DOCS=OFF"

RDEPENDS_${PN}-ptest += "bash"

inherit cmake lib_package ptest

do_install_ptest_class-target() {
	install -m 755 ${B}/tests/* ${D}${PTEST_PATH}
}

BBCLASSEXTEND += "native nativesdk"

CVE_PRODUCT = "expat libexpat"
