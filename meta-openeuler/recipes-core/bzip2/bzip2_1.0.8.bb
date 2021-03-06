SUMMARY = "Very high-quality data compression program"
DESCRIPTION = "bzip2 compresses files using the Burrows-Wheeler block-sorting text compression algorithm, and \
Huffman coding. Compression is generally considerably better than that achieved by more conventional \
LZ77/LZ78-based compressors, and approaches the performance of the PPM family of statistical compressors."
HOMEPAGE = "https://sourceware.org/bzip2/"
SECTION = "console/utils"
LICENSE = "bzip2-1.0.6 & GPLv3+ & Apache-2.0 & MS-PL & BSD-3-Clause & Zlib"
LICENSE_${PN} = "bzip2-1.0.6"
LICENSE_${PN}-dev = "bzip2-1.0.6"
LICENSE_${PN}-dbg = "bzip2-1.0.6"
LICENSE_${PN}-doc = "bzip2-1.0.6"
LICENSE_${PN}-src = "bzip2-1.0.6"
LICENSE_libbz2 = "bzip2-1.0.6"
LICENSE_${PN}-ptest = "bzip2-1.0.6 & GPLv3+ & Apache-2.0 & MS-PL & BSD-3-Clause & Zlib"

LIC_FILES_CHKSUM = "file://LICENSE;beginline=4;endline=37;md5=600af43c50f1fcb82e32f19b32df4664 \
"
#git://sourceware.org/git/bzip2-tests.git;name=bzip2-tests

SRC_URI = "file://bzip2/bzip2-${PV}.tar.gz \
           file://bzip2/0001-add-compile-option.patch \
           file://bzip2/0002-CVE-2019-12900.patch \
           file://configure.ac;subdir=${BP} \
           file://Makefile.am;subdir=${BP} \
           file://run-ptest \
           "
SRC_URI[md5sum] = "67e051268d0c475ea773822f7500d0e5"
SRC_URI[sha256sum] = "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"

SRCREV_bzip2-tests = "f9061c030a25de5b6829e1abf373057309c734c0"

UPSTREAM_CHECK_URI = "https://www.sourceware.org/pub/bzip2/"

PACKAGES =+ "libbz2"

CFLAGS_append = " -fPIC -fpic -Winline -fno-strength-reduce -D_FILE_OFFSET_BITS=64"

#inherit autotools update-alternatives ptest relative_symlinks
inherit autotools ptest relative_symlinks

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_${PN} = "bunzip2 bzcat bzip2"

#install binaries to bzip2-native under sysroot for replacement-native
EXTRA_OECONF_append_class-native = " --bindir=${STAGING_BINDIR_NATIVE}/${PN}"

do_configure_prepend () {
    sed -i -e "s|%BZIP2_VERSION%|${PV}|" ${S}/configure.ac
}

do_install_ptest () {
	install -d ${D}${PTEST_PATH}/bzip2-tests
	sed -i -e "s|^Makefile:|_Makefile:|" ${D}${PTEST_PATH}/Makefile
}
FILES_libbz2 = "${libdir}/lib*${SOLIBS}"

RDEPENDS_${PN}-ptest += "make bash"

PROVIDES_append_class-native = " bzip2-replacement-native"
BBCLASSEXTEND = "native nativesdk"
