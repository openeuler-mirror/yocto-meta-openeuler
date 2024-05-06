SUMMARY = "Inter-process communication (IPC) and Remote Procedure Call (RPC)"
DESCRIPTION = "The inter-process communication (IPC) and remote procedure call (RPC) mechanisms are used to implement cross-process communication."
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-ipc = "communication_ipc-${openHarmony_release_version}"
pkg-dsoftbus = "communication_dsoftbus-${openHarmony_release_version}"
pkg-libcoap = "third_party_libcoap-${openHarmony_release_version}"
pkg-mbedtls = "third_party_mbedtls-${openHarmony_release_version}"
pkg-sqlite = "third_party_sqlite-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "communication_ipc"

SRC_URI += " \
            file://${pkg-ipc}.tar.gz \
            file://communication_ipc/0001-remove-dependence-on-access-token-and-hitrace.patch;patchdir=${WORKDIR}/communication_ipc \
            file://communication_ipc/0002-fix-build-error-from-header-include.patch;patchdir=${WORKDIR}/communication_ipc \
            file://communication_ipc/0005-feat-for-embedded-fix-ipc-compile-error.patch;patchdir=${WORKDIR}/communication_ipc \
            file://${pkg-dsoftbus}.tar.gz \
            file://communication_ipc/0004-adapt-compilation-for-softbus_client.patch;patchdir=${WORKDIR}/${pkg-dsoftbus} \
            file://communication_ipc/0006-feat-for-embedded-fix-dsoftbus-compile-errors.patch;patchdir=${WORKDIR}/${pkg-dsoftbus} \
            file://${pkg-libcoap}.tar.gz \
            file://${pkg-mbedtls}.tar.gz \
            file://${pkg-sqlite}.tar.gz \
            file://communication_ipc/0007-feat-for-embedded-fix-sqlite-stringop-warning.patch;patchdir=${WORKDIR}/${pkg-sqlite} \
            file://communication_ipc/ipc.bundle.json \
            file://communication_ipc/ipc.BUILD.gn \
            file://communication_ipc/ipc_core.BUILD.gn \
            file://communication_ipc/ipc_single.BUILD.gn \
            file://communication_ipc/binder.BUILD.gn \
            file://communication_ipc/mbedtls.BUILD.gn \
            file://communication_ipc/dsoftbus.bundle.json \
            file://communication_ipc/dsoftbus.BUILD.gn \
            file://communication_ipc/sdk.BUILD.gn \
            "

DEPENDS += "hilog c-utils distributed-beget eventhandler openssl cjson binder"

RDEPENDS:${PN} = "libboundscheck binder"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/

    mkdir -p ${S}/foundation/communication/ipc/
    cp -rf ${WORKDIR}/communication_ipc/* ${S}/foundation/communication/ipc/

    mkdir -p ${S}/foundation/communication/dsoftbus/
    cp -rf ${WORKDIR}/${pkg-dsoftbus}/* ${S}/foundation/communication/dsoftbus/

    mkdir -p ${S}/third_party/libcoap/
    cp -rf ${WORKDIR}/${pkg-libcoap}/* ${S}/third_party/libcoap/

    mkdir -p ${S}/third_party/mbedtls/
    cp -rf ${WORKDIR}/${pkg-mbedtls}/* ${S}/third_party/mbedtls/

    mkdir -p ${S}/third_party/sqlite/
    cp -rf ${WORKDIR}/${pkg-sqlite}/* ${S}/third_party/sqlite/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/ipc
    install -d -m 0755 ${D}/${includedir}/mbedtls
    install -d -m 0755 ${D}/${includedir}/dsoftbus
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/system/lib64/

    # install libs and headers from ipc
    install -m 0755 ${S}/out/openeuler/linux_arm64/communication/ipc/*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libdbinder.z.so ${D}/system/lib64/libdbinder.z.so
    ln -s ../../${libdir}/libipc_core.z.so ${D}/system/lib64/libipc_core.z.so
    ln -s ../../${libdir}/libipc_single.z.so ${D}/system/lib64/libipc_single.z.so
    find ${S}/out/openeuler/innerkits/linux-arm64/ipc/ -name *.h -print0 | xargs -0 -i cp -rf {} ${D}/${includedir}/ipc/

    # install libs and headers from dsoftbus
    rm -f ${S}/out/openeuler/linux_arm64/communication/dsoftbus/libsoftbus_server.z.so
    install -m 0755 ${S}/out/openeuler/linux_arm64/communication/dsoftbus/*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libcoap.z.so ${D}/system/lib64/libcoap.z.so
    ln -s ../../${libdir}/libFillpSo.open.z.so ${D}/system/lib64/libFillpSo.open.z.so
    ln -s ../../${libdir}/libnstackx_congestion.open.z.so ${D}/system/lib64/libnstackx_congestion.open.z.so
    ln -s ../../${libdir}/libnstackx_ctrl.z.so ${D}/system/lib64/libnstackx_ctrl.z.so
    ln -s ../../${libdir}/libnstackx_dfile.open.z.so ${D}/system/lib64/libnstackx_dfile.open.z.so
    ln -s ../../${libdir}/libnstackx_util.open.z.so ${D}/system/lib64/libnstackx_util.open.z.so
    ln -s ../../${libdir}/libsoftbus_adapter.z.so ${D}/system/lib64/libsoftbus_adapter.z.so
    ln -s ../../${libdir}/libsoftbus_client.z.so ${D}/system/lib64/libsoftbus_client.z.so
    ln -s ../../${libdir}/libsoftbus_utils.z.so ${D}/system/lib64/libsoftbus_utils.z.so
    
    find ${S}/out/openeuler/innerkits/linux-arm64/dsoftbus/ -name *.h -print0 | xargs -0 -i cp -rvf {} ${D}/${includedir}/dsoftbus/

    # install libs and headers from third party components
    install -m 0755 ${S}/out/openeuler/linux_arm64/common/common/*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libcjson.z.so ${D}/system/lib64/libcjson.z.so
    ln -s ../../${libdir}/libsec_shared.z.so ${D}/system/lib64/libsec_shared.z.so
    ln -s ../../${libdir}/libsqlite.z.so ${D}/system/lib64/libsqlite.z.so

    install -m 0755 ${S}/out/openeuler/linux_arm64/common/dsoftbus/*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libmbedtls.z.so ${D}/system/lib64/libmbedtls.z.so

    install -m 554 ${S}/third_party/mbedtls/include/mbedtls/*.h ${D}/${includedir}/mbedtls/
    install -m 554 ${S}/foundation/communication/dsoftbus/interfaces/kits/common/softbus_error_code.h ${D}/${includedir}/dsoftbus/
    install -m 554 ${S}/foundation/communication/dsoftbus/interfaces/inner_kits/transport/inner_session.h ${D}/${includedir}/dsoftbus/
    install -m 554 ${S}/foundation/communication/ipc/interfaces/innerkits/libdbinder/include/* ${D}/${includedir}/ipc/
    install -m 554 ${S}/foundation/communication/dsoftbus/sdk/transmission/session/cpp/include/* ${D}/${includedir}/ipc/

    #copy gn files
    mkdir -p ${D}/compiler_gn/foundation/communication/dsoftbus/sdk/
    mkdir -p ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/ipc_core/
    mkdir -p ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/ipc_single/
    mkdir -p ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/libdbinder/
    mkdir -p ${D}/compiler_gn/third_party/mbedtls/

    cp -rf ${WORKDIR}/communication_ipc/ipc.bundle.json  ${D}/compiler_gn/foundation/communication/ipc/bundle.json
    cp -rf ${WORKDIR}/communication_ipc/ipc.BUILD.gn  ${D}/compiler_gn/foundation/communication/ipc/BUILD.gn
    cp -rf ${WORKDIR}/communication_ipc/ipc_core.BUILD.gn ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/ipc_core/BUILD.gn
    cp -rf ${WORKDIR}/communication_ipc/ipc_single.BUILD.gn ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/ipc_single/BUILD.gn

    cp -rf ${WORKDIR}/communication_ipc/binder.BUILD.gn ${D}/compiler_gn/foundation/communication/ipc/interfaces/innerkits/libdbinder/BUILD.gn
    
    cp -rf ${WORKDIR}/communication_ipc/mbedtls.BUILD.gn ${D}/compiler_gn/third_party/mbedtls/BUILD.gn

    cp -rf ${WORKDIR}/communication_ipc/dsoftbus.bundle.json ${D}/compiler_gn/foundation/communication/dsoftbus/bundle.json
    cp -rf ${WORKDIR}/communication_ipc/dsoftbus.BUILD.gn ${D}/compiler_gn/foundation/communication/dsoftbus/BUILD.gn
    cp -rf ${WORKDIR}/communication_ipc/sdk.BUILD.gn ${D}/compiler_gn/foundation/communication/dsoftbus/sdk/BUILD.gn
}

SYSROOT_DIRS += "/compiler_gn"