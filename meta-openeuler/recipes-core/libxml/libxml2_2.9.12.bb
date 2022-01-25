SUMMARY = "XML C Parser Library and Toolkit"
DESCRIPTION = "The XML Parser Library allows for manipulation of XML files.  Libxml2 exports Push and Pull type parser interfaces for both XML and HTML.  It can do DTD validation at parse time, on a parsed document instance or with an arbitrary DTD.  Libxml2 includes complete XPath, XPointer and Xinclude implementations.  It also has a SAX like interface, which is designed to be compatible with Expat."
HOMEPAGE = "http://www.xmlsoft.org/"
BUGTRACKER = "http://bugzilla.gnome.org/buglist.cgi?product=libxml2"
SECTION = "libs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://Copyright;md5=2044417e2e5006b65a8b9067b683fcf1 \
                    file://hash.c;beginline=6;endline=15;md5=e77f77b12cb69e203d8b4090a0eee879 \
                    file://list.c;beginline=4;endline=13;md5=b9c25b021ccaf287e50060602d20f3a7 \
                    file://trio.c;beginline=5;endline=14;md5=cd4f61e27f88c1d43df112966b1cd28f \
"

DEPENDS = "zlib virtual/libiconv"

SRC_URI = "file://libxml2/${BP}.tar.gz \
           file://libxml2/libxml2-multilib.patch \
           file://libxml2/Fix-XPath-recursion-limit.patch \
           file://libxml2/Fix-Null-deref-in-xmlSchemaGetComponentTargetNs.patch \
           file://libxml2/Fix-memleaks-in-xmlXIncludeProcessFlags.patch \
           file://libxml2/Fix-heap-use-after-free-in-xmlAddNextSibling-and-xmlAddChild.patch \
           file://libxml2/Work-around-lxml-API-abuse.patch \
           file://libxml2/Fix-regression-in-xmlNodeDumpOutputInternal.patch \
           file://libxml2/Fix-whitespace-when-serializing-empty-HTML-documents.patch \
           file://libxml2/Patch-to-forbid-epsilon-reduction-of-final-states.patch \
           file://libxml2/Fix-buffering-in-xmlOutputBufferWrite.patch \
           file://run-ptest \
           "

SRC_URI[sha256sum] = "c8d6681e38c56f172892c85ddc0852e1fd4b53b4209e7f4ebf17f7e2eae71d92"

BINCONFIG = "${bindir}/xml2-config"

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)}"

PACKAGECONFIG[python] = "--with-python=${PYTHON},--without-python,python3"
PACKAGECONFIG[ipv6] = "--enable-ipv6,--disable-ipv6,"

inherit autotools pkgconfig binconfig-disabled ptest python3native

RDEPENDS_${PN}-ptest += "make ${@bb.utils.contains('PACKAGECONFIG', 'python', 'libgcc python3-core python3-logging python3-shell  python3-stringold python3-threading python3-unittest ${PN}-python', '', d)}"

RDEPENDS_${PN}-python += "${@bb.utils.contains('PACKAGECONFIG', 'python', 'python3-core', '', d)}"

RDEPENDS_${PN}-ptest_append_libc-glibc = " glibc-gconv-ebcdic-us \
                                           glibc-gconv-ibm1141 \
                                           glibc-gconv-iso8859-5 \
                                           glibc-gconv-euc-jp \
                                           locale-base-en-us \
                                         "

export PYTHON_SITE_PACKAGES="${PYTHON_SITEPACKAGES_DIR}"

# WARNING: zlib is required for RPM use
EXTRA_OECONF = "--without-debug --without-legacy --with-catalog --without-docbook --with-c14n --without-lzma --with-fexceptions"
EXTRA_OECONF_class-native = "--without-legacy --without-docbook --with-c14n --without-lzma --with-zlib"
EXTRA_OECONF_class-nativesdk = "--without-legacy --without-docbook --with-c14n --without-lzma --with-zlib"
EXTRA_OECONF_linuxstdbase = "--with-debug --with-legacy --with-docbook --with-c14n --without-lzma --with-zlib"

python populate_packages_prepend () {
    # autonamer would call this libxml2-2, but we don't want that
    if d.getVar('DEBIAN_NAMES'):
        d.setVar('PKG_libxml2', '${MLPREFIX}libxml2')
}

PACKAGE_BEFORE_PN += "${PN}-utils"
PACKAGES += "${PN}-python"

FILES_${PN}-staticdev += "${PYTHON_SITEPACKAGES_DIR}/*.a"
FILES_${PN}-dev += "${libdir}/xml2Conf.sh ${libdir}/cmake/*"
FILES_${PN}-utils = "${bindir}/*"
FILES_${PN}-python = "${PYTHON_SITEPACKAGES_DIR}"

do_compile_ptest() {
	oe_runmake check-am
}

do_install_ptest () {
	cp -r ${S}/xmlconf ${D}${PTEST_PATH}
	if [ "${@bb.utils.filter('PACKAGECONFIG', 'python', d)}" ]; then
		sed -i -e 's|^\(PYTHON = \).*|\1${USRBINPATH}/${PYTHON_PN}|' \
		    ${D}${PTEST_PATH}/python/tests/Makefile
		grep -lrZ '#!/usr/bin/python' ${D}${PTEST_PATH}/python |
			xargs -0 sed -i -e 's|/usr/bin/python|${USRBINPATH}/${PYTHON_PN}|'
	fi
	#Remove build host references from various Makefiles
	find "${D}${PTEST_PATH}" -name Makefile -type f -exec \
	    sed -i \
	    -e 's,--sysroot=${STAGING_DIR_TARGET},,g' \
	    -e 's|${DEBUG_PREFIX_MAP}||g' \
	    -e 's:${HOSTTOOLS_DIR}/::g' \
	    -e 's:${RECIPE_SYSROOT_NATIVE}::g' \
	    -e 's:${RECIPE_SYSROOT}::g' \
	    -e 's:${BASE_WORKDIR}/${MULTIMACH_TARGET_SYS}::g' \
	    -e '/^RELDATE/d' \
	    {} +
}

do_install_append_class-native () {
	# Docs are not needed in the native case
	rm ${D}${datadir}/gtk-doc -rf
}

BBCLASSEXTEND = "native nativesdk"
