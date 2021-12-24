SUMMARY = "Library for parsing command line options"
DESCRIPTION = "Popt is a C library for parsing command line parameters. Popt was heavily influenced by the getopt() and getopt_long() functions, but it improves on them by allowing more powerful argument expansion. Popt can parse arbitrary argv[] style arrays and automatically set variables based on command line arguments."
HOMEPAGE = "https://www.rpm.org/"
SECTION = "libs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=cb0613c30af2a8249b8dcc67d3edb06d"

DEPENDS = "virtual/libiconv"

SRC_URI = "file://popt/${BP}.tar.gz \
	   file://popt/fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
	   file://popt/fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
	   file://popt/fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
	   file://popt/fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
"
SRC_URI[sha256sum] = "5159bc03a20b28ce363aa96765f37df99ea4d8850b1ece17d1e6ad5c24fdc5d1"

inherit autotools gettext

BBCLASSEXTEND = "native nativesdk"
