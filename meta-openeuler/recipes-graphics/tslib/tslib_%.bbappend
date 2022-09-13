PV = "1.16"
SRC_URI = "file://tslib-${PV}.tar.bz2 \
           file://ts.conf \
           file://tslib.sh"
SRCREV = "e17263ef401ee885a27d649b90b577cfb44500e0"
S = "${WORKDIR}/tslib-${PV}"
LIC_FILES_CHKSUM = "file://COPYING;md5=fc178bcd425090939a8b634d1d6a9594"
# avoid QA error regarding /usr/bin/ts_test_mt /usr/bin/ts_finddev /usr/bin/ts_uinput /usr/bin/ts_print_mt /usr/bin/ts_verify not in package
FILES_${PN} += " /usr/bin/ts_*"
