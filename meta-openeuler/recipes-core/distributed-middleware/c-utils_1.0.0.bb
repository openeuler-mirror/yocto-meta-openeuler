SUMMARY = "C++ common basic library for distributed module construction and operation"
DESCRIPTION = "Provide some commonly used C++ development tool classes for standard systems, This repository is compatible with compilation on the OpenEuler operating system"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-c-utils = "commonlibrary_c_utils-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "commonlibrary_c_utils"

SRC_URI += " \
            file://commonlibrary_c_utils/${pkg-c-utils}.tar.gz \
            file://commonlibrary_c_utils/0000-commonlibrary-c_utils.patch;patchdir=${WORKDIR}/${pkg-c-utils} \
            file://commonlibrary_c_utils/0001-commonlibrary-c_utils-linux-ashmem.h.patch;patchdir=${WORKDIR}/${pkg-c-utils} \
            "

DEPENDS += "hilog"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir}"
FILES:${PN} = "${libdir} ${bindir}"

do_patch:append() {
    bb.build.exec_func('do_prepare_hilog_gn_directory', d)
    bb.build.exec_func('do_prepare_c_utils_directory', d)
}

do_prepare_c_utils_directory() {
    mkdir -p ${S}/commonlibrary/c_utils/
    cp -rfp ${WORKDIR}/${pkg-c-utils}/* ${S}/commonlibrary/c_utils/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d ${D}/${libdir}/
    install -d ${D}/${includedir}/c_utils/
    install -d ${D}/${includedir}/c_utils/linux/
    install -d ${D}/${includedir}/src/

    # install so
    install -m 0755 ${S}/out/openeuler/linux_arm64/commonlibrary/c_utils/libutils.z.so ${D}/${libdir}/

    # install head files
    install -m 554 ${S}/commonlibrary/c_utils/base/include/*.h  ${D}/${includedir}/c_utils/
    install -m 554 ${S}/commonlibrary/c_utils/base/include/linux/*.h  ${D}/${includedir}/c_utils/linux/
    install -m 554 ${S}/commonlibrary/c_utils/base/src/event_reactor.h  ${D}/${includedir}/src/
}