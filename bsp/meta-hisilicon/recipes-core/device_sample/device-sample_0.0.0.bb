SUMMARY = "hieuler device sample"
DESCRIPTION = "device samples of hieulerpi"
HOMEPAGE = "https://gitee.com/HiEuler/externed_device_sample"
LICENSE = "CLOSED"

inherit pkgconfig

OPENEULER_LOCAL_NAME = "externed_device_sample"

SRC_URI = " \
        file://HiEuler-driver/drivers/lib.tar.gz \
        file://HiEuler-driver/drivers/include.tar.gz \
        file://externed_device_sample \
"

RDEPENDS:${PN} = "hieulerpi1-user-driver"

S = "${WORKDIR}"

do_compile:prepend () {
    rm -rf ${S}/externed_device_sample/mpp/out
    mkdir -p ${S}/externed_device_sample/mpp/out
    cp -r -P ${WORKDIR}/lib ${S}/externed_device_sample/mpp/out/
    cp -r -P ${WORKDIR}/include ${S}/externed_device_sample/mpp/out/
}

do_compile () {
    pushd externed_device_sample
    oe_runmake
    popd
}

do_install () {
    install -d ${D}/root/
    cp -r externed_device_sample/output ${D}/root/device_sample
}

FILES:${PN} = " \
    /root/device_sample \
"

INSANE_SKIP:${PN} += "already-stripped"
