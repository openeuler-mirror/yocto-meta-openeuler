# apply openeuler source package
OPENEULER_REPO_NAME = "raspberrypi-bluetooth"

PV = "87248a382d1a81b80a62730975135d87fffd7ef1"

SRC_URI = "\
    file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

do_install:append() {
    # we do not use udev package, so pass /dev/ttyAMA0 directly.
    sed -i "s/\/dev\/serial1/\/dev\/ttyAMA0/g" ${D}${bindir}/btuart
}
