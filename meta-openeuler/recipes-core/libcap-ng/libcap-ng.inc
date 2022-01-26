SUMMARY = "An alternate posix capabilities library"
DESCRIPTION = "The libcap-ng library is intended to make programming \
with POSIX capabilities much easier than the traditional libcap library."
HOMEPAGE = "http://freecode.com/projects/libcap-ng"
SECTION = "base"
LICENSE = "GPLv2+ & LGPLv2.1+"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f \
		    file://COPYING.LIB;md5=e3eda01d9815f8d24aae2dbd89b68b06"

SRC_URI = "file://libcap-ng/${BP}.tar.gz"

S = "${WORKDIR}/${BP}"

SRC_URI[md5sum] = "faf1ef766cf068ad1aba4008ced665f7"
SRC_URI[sha256sum] = "52c083b77c2b0d8449dee141f9c3eba76e6d4c5ad44ef05df25891126cb85ae9"

BBCLASSEXTEND = "native nativesdk"
