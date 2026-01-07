DESCRIPTION = "use yocto to re-compile ko libs and initscripts for hieulerpi1, just for kernel 6.6"
SECTION = "base"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=34d15ab872e1eb3db3292ffb63006766"

inherit module oee-archive
OEE_ARCHIVE_SUB_DIR = "mbedtls"

DEPENDS = "update-rc.d-native"

OPENEULER_LOCAL_NAME = "Hispark-ss928v100-gcc-sdk"

SRC_URI = " \
        file://Hispark-ss928v100-gcc-sdk \
        file://0001-yocto-928-sdk-build-support.patch \
        file://0002-fix-928-sdk-cipher-invalid.patch \
        file://0002-feat-mpp-Sensor.patch \
        file://load_sdk_driver \
        file://v2.16.10.tar.gz;unpack=0 \
        file://sdk-fix-mbedtls-err-2.16.10.patch.in \
"

S = "${WORKDIR}/Hispark-ss928v100-gcc-sdk"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "/root/sample"

do_compile() {
    cp -f ${WORKDIR}/v2.16.10.tar.gz ${S}/open_source/mbedtls/mbedtls-2.16.10.tar.gz
    cp -f ${WORKDIR}/sdk-fix-mbedtls-err-2.16.10.patch.in ${S}/open_source/mbedtls/sdk-fix-mbedtls-err-2.16.10.patch.in
    export KERNEL_ROOT=${STAGING_KERNEL_BUILDDIR}
    cd ${S}/smp/a55_linux/mpp/out/obj
    oe_runmake
    cd -
}

do_install () {
    cd ${S}/smp/a55_linux/mpp/out/
    install -m 0750 ${WORKDIR}/load_sdk_driver ko/
    tar czf ko.tar.gz ko/
    cd - 
}

do_deploy[nostamp] = "1"
do_deploy() {
    install -d ${DEPLOY_DIR}/third_party_sdk
    install -m 0644 ${S}/smp/a55_linux/mpp/out/ko.tar.gz ${DEPLOY_DIR}/third_party_sdk
}

addtask deploy after do_install

