SUMMARY = "dsoftbus"
DESCRIPTION = "dsoftbus"
PR = "r1"
LICENSE = "CLOSED"

# gn\ninja has self contained by this project, no need here
DEPENDS = "python3-native"

S = "${WORKDIR}/dsoftbus-build"
dsoftbus-buildtools="${S}/prebuilts/build-tools/linux-x86/bin"
dsoftbus-thirdparty="${S}/third_party"
dsoftbus-utils="${S}/utils"
dsoftbus-src="${S}/foundation/communication"

SRC_URI = " \
        file://libboundscheck/libboundscheck-v1.1.11.tar.gz \
        file://yocto-embedded-tools/dsoftbus/build/build-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/build_tools/gn-linux-x86-1717.tar.gz \
        file://yocto-embedded-tools/dsoftbus/build_tools/ninja-linux-x86-1.10.1.tar.gz \
        file://yocto-embedded-tools/dsoftbus/third_party/cJSON/third_party_cJSON-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/third_party/jinja2/third_party_jinja2-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/third_party/libcoap/third_party_libcoap-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/third_party/markupsafe/third_party_markupsafe-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/third_party/mbedtls/third_party_mbedtls-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/utils/utils_native-OpenHarmony-v3.0.2-LTS.zip \
        file://yocto-embedded-tools/dsoftbus/depend;unpack=true \
        file://yocto-embedded-tools/dsoftbus/productdefine;unpack=true \
        file://dsoftbus_standard;unpack=true \
        file://yocto-embedded-tools/dsoftbus/build/0001-add-dsoftbus-build-support-for-embedded-env.patch;patchdir=${S}/build \
        file://yocto-embedded-tools/dsoftbus/utils/0001-Adaptation-for-dsoftbus.patch;patchdir=${dsoftbus-utils}/native \
        file://yocto-embedded-tools/dsoftbus/bounds_checking_function/0001-Adaptation-for-dsoftbus.patch;patchdir=${dsoftbus-thirdparty}/bounds_checking_function \
        "

FILES_${PN}-dev = "${includedir}"
FILES_${PN} = "${libdir} ${bindir} /data/"

INSANE_SKIP_${PN} += "already-stripped"
ALLOW_EMPTY_${PN} = "1"

do_unpack_append() {
    bb.build.exec_func('do_copy_dsoftbus_source', d)
}

do_copy_dsoftbus_source() {
    mkdir -p ${S}/build
    mkdir -p ${dsoftbus-buildtools}
    mkdir -p ${dsoftbus-thirdparty}
    mkdir -p ${dsoftbus-utils}
    mkdir -p ${dsoftbus-src}
    mkdir -p ${dsoftbus-thirdparty}/cJSON
    mkdir -p ${dsoftbus-thirdparty}/jinja2
    mkdir -p ${dsoftbus-thirdparty}/libcoap
    mkdir -p ${dsoftbus-thirdparty}/markupsafe
    mkdir -p ${dsoftbus-thirdparty}/mbedtls
    mkdir -p ${dsoftbus-thirdparty}/bounds_checking_function
    mkdir -p ${dsoftbus-utils}/native/
    cp -rfp ${WORKDIR}/build-OpenHarmony-v3.0.2-LTS/* ${S}/build/
    cp -rfp ${WORKDIR}/gn ${dsoftbus-buildtools}/
    cp -rfp ${WORKDIR}/ninja ${dsoftbus-buildtools}/
    cp -rfp ${WORKDIR}/third_party_cJSON-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-thirdparty}/cJSON/
    cp -rfp ${WORKDIR}/third_party_jinja2-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-thirdparty}/jinja2/
    cp -rfp ${WORKDIR}/third_party_libcoap-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-thirdparty}/libcoap/
    cp -rfp ${WORKDIR}/third_party_markupsafe-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-thirdparty}/markupsafe/
    cp -rfp ${WORKDIR}/third_party_mbedtls-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-thirdparty}/mbedtls/
    cp -rfp ${WORKDIR}/libboundscheck-v1.1.11/* ${dsoftbus-thirdparty}/bounds_checking_function/
    cp -rfp ${WORKDIR}/utils_native-OpenHarmony-v3.0.2-LTS/* ${dsoftbus-utils}/native/

    #init gn root
    ln -s ${S}/build/build_scripts/build.sh ${S}/build.sh
    ln -s ${S}/build/core/gn/dotfile.gn ${S}/.gn

    #link selfcode
    ln -s ${WORKDIR}/yocto-embedded-tools/dsoftbus/productdefine ${S}/productdefine
    ln -s ${WORKDIR}/yocto-embedded-tools/dsoftbus/depend ${S}/depend
    ln -s ${WORKDIR}/dsoftbus_standard ${dsoftbus-src}/dsoftbus

    #link toolchain
    ln -s ${EXTERNAL_TOOLCHAIN} ${S}/toolchain
}

do_compile() {
    ./build.sh --product-name openEuler
}

do_install() {
    install -d ${D}${libdir}/
    install -d ${D}${bindir}/
    install -d ${D}/${includedir}/dsoftbus/
    install -d ${D}/data/data/

    # prepare so
    install -m 0755 ${S}/out/ohos-arm64-release/common/common/*.so ${D}${libdir}/
    install -m 0755 ${S}/out/ohos-arm64-release/communication/dsoftbus_standard/*.so ${D}${libdir}/

    # prepare bin
    install -m 0755  ${S}/out/ohos-arm64-release/communication/dsoftbus_standard/softbus_server_main ${D}${bindir}/

    # prepare head files
    install -m 554 \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/discovery/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/common/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/bus_center/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/transport/*.h \
        ${S}/foundation/communication/dsoftbus/core/common/include/softbus_errcode.h \
            ${D}${includedir}/dsoftbus/
}
