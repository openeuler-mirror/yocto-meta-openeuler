SUMMARY = "C bindings for apps which will manipulate JSON data"
DESCRIPTION = "JSON-C implements a reference counting object model that allows you to easily construct JSON objects in C."
HOMEPAGE = "https://github.com/json-c/json-c/wiki"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=de54b60fbbc35123ba193fea8ee216f2"

SRC_URI = "file://json-c/json-c-0.15-20200726.tar.gz"

SRC_URI[sha256sum] = "4ba9a090a42cf1e12b84c64e4464bb6fb893666841d5843cc5bef90774028882"
UPSTREAM_CHECK_URI = "https://github.com/${BPN}/${BPN}/releases"
UPSTREAM_CHECK_REGEX = "json-c-(?P<pver>\d+(\.\d+)+)-\d+"
S = "${WORKDIR}/json-c-json-c-0.15-20200726"
RPROVIDES_${PN} = "libjson"

inherit cmake
BBCLASSEXTEND = "native nativesdk"
