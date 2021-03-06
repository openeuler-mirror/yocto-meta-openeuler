require libcap-ng.inc


inherit lib_package autotools
DEPENDS_remove += "libtool-cross"

EXTRA_OECONF += "--without-python --without-python3"

BBCLASSEXTEND = "native nativesdk"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

do_install_append() {
	# Moving libcap-ng to base_libdir
	if [ ! ${D}${libdir} -ef ${D}${base_libdir} ]; then
		mkdir -p ${D}/${base_libdir}/
		mv -f ${D}${libdir}/libcap-ng.so.* ${D}${base_libdir}/
		relpath=${@os.path.relpath("${base_libdir}", "${libdir}")}
		ln -sf ${relpath}/libcap-ng.so.0.0.0 ${D}${libdir}/libcap-ng.so
	fi
}
