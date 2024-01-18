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

S = "${WORKDIR}"

do_compile:prepend () {
    rm -rf ${S}/externed_device_sample/mpp/out
    mkdir ${S}/externed_device_sample/mpp/out
    cp -r -P ${WORKDIR}/lib ${S}/externed_device_sample/mpp/out/
    cp -r -P ${WORKDIR}/include ${S}/externed_device_sample/mpp/out/
}

do_compile () {
    pushd externed_device_sample
    pwd
    oe_runmake
    popd
    pushd externed_device_sample/mpp/sample/audio
    oe_runmake
    popd
    pushd externed_device_sample/mpp/sample/hdmi
    oe_runmake
    popd
}

do_install () {
    install -d ${D}/root/
    mkdir -p ${D}/root/device_sample/source_file

    install -m 0755 externed_device_sample/test ${D}/root/device_sample/test
    install -m 0755 externed_device_sample/mpp/sample/audio/sample_audio ${D}/root/device_sample/sample_audio
    cp -rf externed_device_sample/mpp/sample/audio/source_file/* ${D}/root/device_sample/source_file/
    install -m 0755 externed_device_sample/mpp/sample/hdmi/sample_hdmi ${D}/root/device_sample/sample_hdmi
    cp -rf externed_device_sample/mpp/sample/hdmi/source_file/* ${D}/root/device_sample/source_file/

}

FILES:${PN} = " \
    /root/device_sample \
"

INSANE_SKIP:${PN} += "already-stripped"

