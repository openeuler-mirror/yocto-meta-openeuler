# main bbfile: https://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-extended/rsyslog/libfastjson_0.99.9.bb

SUMMARY = "A fork of json-c library"
HOMEPAGE = "https://github.com/rsyslog/libfastjson"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=a958bb07122368f3e1d9b2efe07d231f"

DEPENDS = ""

# obatin source from local tarball
SRC_URI = "file://${BPN}/${BP}.tar.gz"

SRC_URI[md5sum] = "b4668f067145d4eb2a44433d5256f277"
SRC_URI[sha256sum] = "a330e1bdef3096b7ead53b4bad1a6158f19ba9c9ec7c36eda57de7729d84aaee"

inherit autotools
