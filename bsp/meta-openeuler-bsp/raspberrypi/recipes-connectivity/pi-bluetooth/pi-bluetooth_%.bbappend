# apply openeuler source package
OPENEULER_REPO_NAME = "raspberrypi-bluetooth"

PV = "23af66cff597c80523bf9581d7f75d387227f183"

SRC_URI = "\
    file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

do_install_append() {
    # we do not use udev package, so pass /dev/ttyAMA0 directly.
    sed -i "s/\/dev\/serial1/\/dev\/ttyAMA0/g" ${D}${bindir}/btuart
}
