SUMMARY = "C++ common basic library for distributed module construction and operation"
DESCRIPTION = "Provide some commonly used C++ development tool classes for standard systems, This repository is compatible with compilation on the OpenEuler operating system"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-eventhandler = "notification_eventhandler-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "notification_eventhandler"

SRC_URI += " \
            file://${pkg-eventhandler}.tar.gz \
            file://notification_eventhandler/0001-notification-eventhandler.patch;patchdir=${WORKDIR}/${pkg-eventhandler} \
            file://notification_eventhandler/0002-feat-for-embedded-fix-eventhandler-compile-errors.patch;patchdir=${WORKDIR}/${pkg-eventhandler} \
            file://notification_eventhandler/eventhandler.bundle.json \
            file://notification_eventhandler/eventhandler.BUILD.gn \
            "

SRC_URI:append = " \
        file://0002-feat-for-embedded-eventhandler-comment-out-cflags.patch;patchdir=${WORKDIR}/${pkg-eventhandler} \
"

DEPENDS += "hilog c-utils"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir}"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/base/notification/eventhandler
    cp -rf ${WORKDIR}/${pkg-eventhandler}/* ${S}/base/notification/eventhandler/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/eventhandler
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    # shared library
    install -m 0755 ${S}/out/openeuler/linux_arm64/notification/eventhandler/libeventhandler_native.z.so ${D}/${libdir}/
    install -m 0755 ${S}/out/openeuler/linux_arm64/notification/eventhandler/libeventhandler.z.so ${D}/${libdir}/
    # header files
    install -m 554 ${S}/base/notification/eventhandler/interfaces/inner_api/*.h ${D}/${includedir}/eventhandler/

    # copy bundle
    mkdir -p ${D}/compiler_gn/base/notification/eventhandler/
    cp -rf ${WORKDIR}/notification_eventhandler/eventhandler.bundle.json ${D}/compiler_gn/base/notification/eventhandler/bundle.json
    cp -rf ${WORKDIR}/notification_eventhandler/eventhandler.BUILD.gn ${D}/compiler_gn/base/notification/eventhandler/BUILD.gn
}

SYSROOT_DIRS += "/compiler_gn"