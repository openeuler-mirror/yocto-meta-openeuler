require gzip.inc

LICENSE = "GPLv3+"

SRC_URI = "file://gzip/${BP}.tar.xz \
           file://gzip/gzip-l-now-outputs-accurate-size.patch \
           file://gzip/doc-document-gzip-l-change.patch \
           file://gzip/zdiff-fix-arg-handling-bug.patch \
           file://gzip/zdiff-fix-another-arg-handling-bug.patch \
           file://gzip/fix-verbose-disable.patch \
           file://run-ptest \
          "
SRC_URI_append_class-target = " file://wrong-path-fix.patch"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://gzip.h;beginline=8;endline=20;md5=6e47caaa630e0c8bf9f1bc8d94a8ed0e"

PROVIDES_append_class-native = " gzip-replacement-native"

RDEPENDS_${PN}-ptest += "make perl grep diffutils"

BBCLASSEXTEND = "native nativesdk"

inherit ptest

do_install_ptest() {
	mkdir -p ${D}${PTEST_PATH}/src/build-aux
	cp ${S}/build-aux/test-driver ${D}${PTEST_PATH}/src/build-aux/
	mkdir -p ${D}${PTEST_PATH}/src/tests
	cp -r ${S}/tests/* ${D}${PTEST_PATH}/src/tests
	sed -e 's/^abs_srcdir = ..*/abs_srcdir = \.\./' \
            -e 's/^top_srcdir = ..*/top_srcdir = \.\./' \
            -e 's/^GREP = ..*/GREP = grep/'             \
            -e 's/^AWK = ..*/AWK = awk/'                \
            -e 's/^srcdir = ..*/srcdir = \./'           \
            -e 's/^Makefile: ..*/Makefile: /'           \
            -e 's,--sysroot=${STAGING_DIR_TARGET},,g'   \
            -e 's|${DEBUG_PREFIX_MAP}||g' \
            -e 's:${HOSTTOOLS_DIR}/::g'                 \
            -e 's:${BASE_WORKDIR}/${MULTIMACH_TARGET_SYS}::g' \
            ${B}/tests/Makefile > ${D}${PTEST_PATH}/src/tests/Makefile
}

SRC_URI[md5sum] = "d1e93996dba00cab0caa7903cd01d454"
SRC_URI[sha256sum] = "9b9a95d68fdcb936849a4d6fada8bf8686cddf58b9b26c9c4289ed0c92a77907"
