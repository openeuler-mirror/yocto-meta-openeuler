SUMMARY = "dsoftbus"
DESCRIPTION = "dsoftbus"
PR = "r1"
LICENSE = "CLOSED"

# gn\ninja has self contained by this project, no need here
inherit python3native
DEPENDS = "ninja-native openssl libboundscheck cjson"

S = "${WORKDIR}/dsoftbus-build"
pkg-build = "build-OpenHarmony-v3.0.2-LTS"
pkg-deviceauth = "security_device_auth-OpenHarmony-v3.1.2-Release"
pkg-huks = "security_huks-OpenHarmony-v3.1.2-Release"
pkg-utils = "commonlibrary_c_utils-OpenHarmony-v3.1.2-Release"
pkg-mebedtls = "third_party_mbedtls-OpenHarmony-v3.1.2-Release"
pkg-libcoap = "third_party_libcoap-OpenHarmony-v3.1.2-Release"

dsoftbus-buildtools = "${S}/prebuilts/build-tools/linux-x86/bin"
dsoftbus-thirdparty = "${S}/third_party"
dsoftbus-utils = "${S}/utils"
dsoftbus-src = "${S}/foundation/communication"
dsoftbus-hichain = "${S}/base/security"
dsoftbus-productdefine = "${S}/productdefine"
dsoftbus-depend = "${S}/depend"

# multi-repos are required to build dsoftbus
OPENEULER_MULTI_REPOS = "yocto-embedded-tools dsoftbus_standard embedded-ipc dsoftbus"

SRC_URI = " \
        file://yocto-embedded-tools/dsoftbus/build_tools/gn-linux-x86-1717.tar.gz \
        file://dsoftbus/${pkg-build}.tar.gz \
        file://dsoftbus/${pkg-deviceauth}.tar.gz \
        file://dsoftbus/${pkg-huks}.tar.gz \
        file://dsoftbus/${pkg-utils}.tar.gz \
        file://dsoftbus/${pkg-mebedtls}.tar.gz \
        file://dsoftbus/${pkg-libcoap}.tar.gz \
        file://dsoftbus_standard;unpack=true \
        file://embedded-ipc;unpack=true \
        file://dsoftbus/build-0001-add-dsoftbus-build-support-for-embedded-env.patch;patchdir=${S}/build \
        file://dsoftbus/build-0002-support-hichian-for-openeuler.patch;patchdir=${S}/build \
        file://dsoftbus/build-0003-add-deviceauth-ipc-sdk-compile.patch;patchdir=${S}/build \
        file://dsoftbus/dsoftbus-standard-0002-fix-mutex-build-error-for-dsoftbus-standard.patch;patchdir=${dsoftbus-src}/dsoftbus \
        file://dsoftbus/security-device-auth-0001-deviceauth-for-openeuler.patch;patchdir=${dsoftbus-hichain}/deviceauth \
        file://dsoftbus/security-device-auth-0002-deviceauth-ipc-service.patch;patchdir=${dsoftbus-hichain}/deviceauth \
        file://dsoftbus/security-device-auth-0003-simplify-dependency-on-third-party-packages.patch;patchdir=${dsoftbus-hichain}/deviceauth \
        file://dsoftbus/security-huks-0001-support-huks-for-openeuler.patch;patchdir=${dsoftbus-hichain}/huks \
        file://dsoftbus/security-huks-0002-simplify-dependency-on-third-party-packages.patch;patchdir=${dsoftbus-hichain}/huks \
        file://dsoftbus/security-huks-0003-fix-discarded-qualifiers-error.patch;patchdir=${dsoftbus-hichain}/huks \
        file://dsoftbus/commonlibrary-c-utils-0001-Adaptation-for-dsoftbus.patch;patchdir=${dsoftbus-utils}/native \
        file://dsoftbus/libboundscheck-0001-Adaptation-for-dsoftbus.patch;patchdir=${dsoftbus-thirdparty}/bounds_checking_function \
        file://dsoftbus/third-party-cjson-0001-adapter-cjson-in-openEuler-for-softbus.patch;patchdir=${dsoftbus-thirdparty}/cJSON \
        file://dsoftbus/third-party-mbedtls-0001-Adaptation-for-dsoftbus.patch;patchdir=${dsoftbus-thirdparty}/mbedtls \
        file://dsoftbus/third-party-mbedtls-0002-fix-CVE-2021-43666.patch;patchdir=${dsoftbus-thirdparty}/mbedtls \
        file://dsoftbus/third-party-mbedtls-0002-fix-CVE-2021-45451.patch;patchdir=${dsoftbus-thirdparty}/mbedtls \
        file://dsoftbus/third-party-libcoap-0003-fix-CVE-2023-30364.patch;patchdir=${dsoftbus-thirdparty}/libcoap \
        file://dsoftbus/depend-0001-add-productdefine-for-openeuler.patch;patchdir=${dsoftbus-productdefine}/ \
        file://dsoftbus/depend-0002-add-depend-for-openeuler.patch;patchdir=${dsoftbus-depend} \
        "

# fix libboundscheck.so not found
RDEPENDS:${PN} = "libboundscheck"

# bluetooth only support for raspberrypi, qemu don't compile it
DEPENDS:append:raspberrypi4-64 = " bluez5"
SRC_URI:append:raspberrypi4-64 = " \
        file://add-bluez-adapter-for-dsoftbus.patch;patchdir=${dsoftbus-depend} \
        file://apply-ble-discovery-support.patch;patchdir=${dsoftbus-src}/dsoftbus \
"

FILES:${PN}-dev = "${includedir}"
FILES:${PN} = "${libdir} ${bindir} /data/"

INSANE_SKIP:${PN} += "already-stripped"
ALLOW_EMPTY:${PN} = "1"

python do_fetch:prepend() {
    bb.build.exec_func("do_openeuler_fetch_multi", d)
}

do_unpack:append() {
    bb.build.exec_func('do_copy_dsoftbus_source', d)
}

do_copy_dsoftbus_source() {
    mkdir -p ${dsoftbus-buildtools}
    mkdir -p ${dsoftbus-src}
    mkdir -p ${dsoftbus-hichain}
    mkdir -p ${dsoftbus-utils}
    mkdir -p ${dsoftbus-thirdparty}
    mkdir -p ${dsoftbus-thirdparty}/cJSON
    mkdir -p ${dsoftbus-thirdparty}/bounds_checking_function
    mkdir -p ${dsoftbus-productdefine}
    mkdir -p ${dsoftbus-depend}

    cp -rfp ${WORKDIR}/gn ${dsoftbus-buildtools}/
    mv ${WORKDIR}/${pkg-build} ${S}/build
    mv ${WORKDIR}/${pkg-deviceauth} ${dsoftbus-hichain}/deviceauth
    mv ${WORKDIR}/${pkg-huks} ${dsoftbus-hichain}/huks
    mv ${WORKDIR}/${pkg-utils} ${dsoftbus-utils}/native
    mv ${WORKDIR}/${pkg-mebedtls} ${dsoftbus-thirdparty}/mbedtls
    mv ${WORKDIR}/${pkg-libcoap} ${dsoftbus-thirdparty}/libcoap
    mv ${WORKDIR}/dsoftbus_standard ${dsoftbus-src}/dsoftbus
    mv ${WORKDIR}/embedded-ipc ${dsoftbus-depend}/ipc

    #init gn root
    ln -s ${S}/build/build_scripts/build.sh ${S}/build.sh
    ln -s ${S}/build/core/gn/dotfile.gn ${S}/.gn

}

# ready for build env
do_configure:prepend() {
    # link python
    if [ ! -e ${STAGING_BINDIR_NATIVE}/python3-native/python ]; then
        ln -s ${STAGING_BINDIR_NATIVE}/python3-native/python3 ${STAGING_BINDIR_NATIVE}/python3-native/python
    fi

    # link ninja
    if [ ! -e ${dsoftbus-buildtools}/ninja ]; then
        ln -s `which ninja` ${dsoftbus-buildtools}/ninja
    fi

    # link toolchain
    if [ ! -e ${S}/toolchain ]; then
        ln -s ${EXTERNAL_TOOLCHAIN} ${S}/toolchain
    fi
}

do_compile() {
    export STAGING_DIR_TARGET="${STAGING_DIR_TARGET}"
    ./build.sh --product-name openEuler
}

do_install() {
    install -d ${D}${libdir}/
    install -d ${D}${bindir}/
    install -d ${D}/${includedir}/
    install -d ${D}/data/data/deviceauth/

    # prepare so
    install -m 0755 ${S}/out/ohos-arm64-release/common/common/*.so ${D}${libdir}/
    install -m 0755 ${S}/out/ohos-arm64-release/communication/dsoftbus_standard/*.so ${D}${libdir}/
    install -m 0755 ${S}/out/ohos-arm64-release/security/huks/*.so ${D}${libdir}/
    install -m 0755 ${S}/out/ohos-arm64-release/security/deviceauth_standard/*.so ${D}${libdir}/

    # prepare bin
    install -m 0755  ${S}/out/ohos-arm64-release/communication/dsoftbus_standard/softbus_server_main ${D}${bindir}/

    # prepare head files
    install -m 554 \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/discovery/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/common/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/bus_center/*.h \
        ${S}/foundation/communication/dsoftbus/interfaces/kits/transport/*.h \
        ${S}/foundation/communication/dsoftbus/core/common/include/softbus_errcode.h \
        ${S}/base/security/deviceauth/interfaces/innerkits/*.h \
        ${S}/depend/syspara/include/*.h \
            ${D}${includedir}/
}
