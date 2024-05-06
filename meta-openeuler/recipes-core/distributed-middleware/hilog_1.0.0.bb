SUMMARY = "OpenEuler supports hilog for distributed softbus capability"
DESCRIPTION = "OpenEuler supports hilog for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

OPENEULER_REPO_NAME = "hiviewdfx_hilog"

pkg-hilog = "hiviewdfx_hilog-${openHarmony_release_version}"

SRC_URI += " \
            file://${pkg-hilog}.tar.gz \
            file://hiviewdfx_hilog/0001-init-and-adapt-to-openeuler.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            file://hiviewdfx_hilog/0002-fix-build-gn-files-config.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            file://hiviewdfx_hilog/0003-feat-set-priv-false.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            file://hiviewdfx_hilog/0004-close-private-print-in-hilog.cpp-file.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            file://hiviewdfx_hilog/0005-feat-for-embedded-comment-out-os_log.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            file://hiviewdfx_hilog/0006-feat-for-embedded-fix-unused-errors.patch;patchdir=${WORKDIR}/${pkg-hilog} \
            "

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir}"

do_configure:prepend() {
    mkdir -p ${S}/base/hiviewdfx/hilog
    cp -rf ${WORKDIR}/${pkg-hilog}/* ${S}/base/hiviewdfx/hilog
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d ${D}/${libdir}/
    install -d ${D}/${includedir}/hilog/
    install -d ${D}/${includedir}/hilog/hilog/
    install -d ${D}/${includedir}/hilog/hilog_base/

    # prepare so
    install -m 0755 ${S}/out/openeuler/packages/phone/system/lib64/libhilog*.so ${D}${libdir}/
    install -m 0755 ${S}/out/openeuler/linux_arm64/obj/base/hiviewdfx/hilog/interfaces/native/innerkits/libhilog_base.a ${D}/${libdir}/

    # prepare head files
    install -m 554 ${S}/base/hiviewdfx/hilog/interfaces/native/innerkits/include/*.h  ${D}/${includedir}/hilog/
    install -m 554 ${S}/base/hiviewdfx/hilog/interfaces/native/innerkits/include/hilog/*.h  ${D}/${includedir}/hilog/hilog/
    install -m 554 ${S}/base/hiviewdfx/hilog/interfaces/native/innerkits/include/hilog_base/*.h  ${D}/${includedir}/hilog/hilog_base/

    # copy gn files
    mkdir -p ${D}/compiler_gn/base/hiviewdfx
    cp -rf ${WORKDIR}/${pkg-build}/openeuler/compiler_gn/base/hiviewdfx/hilog/ ${D}/compiler_gn/base/hiviewdfx/
}

SYSROOT_DIRS += "/compiler_gn"