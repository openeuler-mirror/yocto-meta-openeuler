SUMMARY = "Inter-process Remote Procedure Call (RPC)"
DESCRIPTION = "The inter-process remote procedure call (RPC) mechanisms are used to implement cross-process communication"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-dsoftbus = "communication_dsoftbus-${openHarmony_release_version}"
pkg-libcoap = "third_party_libcoap-${openHarmony_release_version}"
pkg-sqlite = "third_party_sqlite-${openHarmony_release_version}"

OPENEULER_LOCAL_NAME = "communication_dsoftbus"
OPENEULER_REPO_NAMES += " communication_ipc"

SRC_URI += " \
            file://${pkg-dsoftbus}.tar.gz;subdir=${pkg-dsoftbus} \
            file://communication_dsoftbus/0001-remove-dependency-and-adapt-for-openeuler-dsoftbus.patch;patchdir=${WORKDIR}/${pkg-dsoftbus}/dsoftbus \
            file://communication_dsoftbus/0002-increase-the-pthread-stack-size-of-x86-and-other-env-dsoftbus.patch;patchdir=${WORKDIR}/${pkg-dsoftbus}/dsoftbus \
            file://communication_dsoftbus/0003-open-udp-stream-switch-dsoftbus.patch;patchdir=${WORKDIR}/${pkg-dsoftbus}/dsoftbus \
            file://communication_ipc/0006-feat-for-embedded-fix-dsoftbus-compile-errors.patch;patchdir=${WORKDIR}/${pkg-dsoftbus}/dsoftbus \
            file://communication_ipc/0007-feat-for-embedded-fix-sqlite-stringop-warning.patch;patchdir=${WORKDIR}/${pkg-sqlite} \
            file://communication_dsoftbus/softbus_server.xml \
            file://softbus_client_main.c \
            file://${pkg-libcoap}.tar.gz \
            file://${pkg-sqlite}.tar.gz \
            "

DEPENDS += "hilog c-utils distributed-beget eventhandler ipc samgr safwk huks device-auth"

RDEPENDS:${PN} = "libboundscheck ipc"

FILES:${PN}-dev = "${includedir}"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/

    mkdir -p ${S}/foundation/communication/dsoftbus/
    cp -rf ${WORKDIR}/${pkg-dsoftbus}/dsoftbus/* ${S}/foundation/communication/dsoftbus/

    mkdir -p ${S}/third_party/libcoap/
    cp -rf ${WORKDIR}/${pkg-libcoap}/* ${S}/third_party/libcoap/

    mkdir -p ${S}/third_party/sqlite/
    cp -rf ${WORKDIR}/${pkg-sqlite}/* ${S}/third_party/sqlite/
}

do_compile() {
    cd ${S}
    # no support clang
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=${is_clang} --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_compile:append() {
    # Build the softbus client demo from the documentation
    CLIENT_LIB=$(find ${S}/out -name "libsoftbus_client.z.so" -print -quit)
    if [ -z "$CLIENT_LIB" ]; then
        bbwarn "libsoftbus_client.z.so not found in build output, skipping demo"
        return
    fi
    CLIENT_LIB_DIR=$(dirname "$CLIENT_LIB")

    # Flatten dsoftbus headers into a temporary include directory
    DSOFTBUS_INC=${B}/dsoftbus_inc
    rm -rf $DSOFTBUS_INC
    mkdir -p $DSOFTBUS_INC
    find ${S}/out/openeuler/innerkits/linux-arm64/dsoftbus/ -name "*.h" -exec cp -f {} $DSOFTBUS_INC/ \;

    ${CC} -o softbus_client_main \
        ${WORKDIR}/softbus_client_main.c \
        -I$DSOFTBUS_INC \
        -I${RECIPE_SYSROOT}${includedir} \
        -L"$CLIENT_LIB_DIR" -lsoftbus_client.z \
        -L${RECIPE_SYSROOT}${libdir} -lboundscheck
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/dsoftbus/
    install -d -m 0755 ${D}/${includedir}/sqlite/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/system/profile/
    install -d -m 0755 ${D}/system/lib64/
    install -d -m 0755 ${D}/system/bin/

    # install headers from dsoftbus
    rm -rf ${S}/out/openeuler/innerkits/linux-arm64/dsoftbus/softbus_client/inner_kits/transport/inner_session.h
    find ${S}/out/openeuler/innerkits/linux-arm64/dsoftbus/ -name *.h -print0 | xargs -0 -i cp -rf {} ${D}/${includedir}/dsoftbus/
    # install server lib from dsoftbus
    install -m 0755 ${S}/out/openeuler/linux_*arm64/communication/dsoftbus/libsoftbus_server.z.so ${D}/${libdir}/
    ln -s ../../${libdir}/libsoftbus_server.z.so ${D}/system/lib64/libsoftbus_server.z.so
    # libsoftbus_client.z.so is provided by the ipc recipe (avoids duplicate)
    # install client demo binary
    if [ -f "${B}/softbus_client_main" ]; then
        install -m 0755 ${B}/softbus_client_main ${D}/system/bin/softbus_client_main
    fi
    # install headers and BUILD.gn from third party sqlite
    install -m 0755 ${S}/third_party/sqlite/include/*.h ${D}/${includedir}/sqlite/
    install -m 0755 ${WORKDIR}/communication_dsoftbus/softbus_server.xml ${D}/system/profile/
}
