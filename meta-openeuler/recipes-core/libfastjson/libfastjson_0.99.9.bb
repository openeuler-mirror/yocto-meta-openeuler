SUMMARY = "A fork of json-c library"
HOMEPAGE = "https://github.com/rsyslog/libfastjson"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=a958bb07122368f3e1d9b2efe07d231f"

SRC_URI = "file://${BPN}/${BP}.tar.gz"
CFLAGS="-lm"

inherit autotools
