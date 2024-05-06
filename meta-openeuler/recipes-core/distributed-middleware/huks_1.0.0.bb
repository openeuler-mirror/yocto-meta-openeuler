SUMMARY = "Key management service"
DESCRIPTION = "OpenHarmony Universal KeyStore (HUKS) provides applications with key library capabilities, such as key management and cryptographic operations on keys. HUKS also provides APIs for applications to import or generate keys"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-huks = "security_huks-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "security_huks"

SRC_URI += " \
            file://${pkg-huks}.tar.gz \
            file://security_huks/0001-adapt-compilation-tailor-dependencies.patch;patchdir=${WORKDIR}/${pkg-huks} \
            file://security_huks/0002-feat-for-embedded-fix-huks-compile-errors.patch;patchdir=${WORKDIR}/${pkg-huks} \
            file://security_huks/huks_service.xml \
            file://security_huks/huks.bundle.json \
            file://security_huks/huks.BUILD.gn \
            "

DEPENDS += "hilog c-utils distributed-beget eventhandler ipc samgr safwk"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/base/security/huks/
    cp -rf ${WORKDIR}/${pkg-huks}/* ${S}/base/security/huks/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/huks/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/system/profile/
    install -d -m 0755 ${D}/system/lib64/

    # prepare head files
    find ${S}/out/openeuler/innerkits/linux-arm64/huks/ -name *.h -print0 | xargs -0 -i cp -rf {} ${D}/${includedir}/huks/
    install -m 544 ${S}/base/security/huks/frameworks/huks_standard/main/common/include/*.h ${D}/${includedir}/huks/
    # copy so file.
    install -m 0755 ${S}/out/openeuler/linux_arm64/security/huks/*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libhuks_engine_core_standard.z.so ${D}/system/lib64/libhuks_engine_core_standard.z.so
    ln -s ../../${libdir}/libhuks_ndk.z.so ${D}/system/lib64/libhuks_ndk.z.so
    ln -s ../../${libdir}/libhukssdk.z.so ${D}/system/lib64/libhukssdk.z.so
    ln -s ../../${libdir}/libhuks_service.z.so ${D}/system/lib64/libhuks_service.z.so

    # cp profile file
    install -m 0755 ${WORKDIR}/security_huks/huks_service.xml ${D}/system/profile/

    # copy bundle
    mkdir -p ${D}/compiler_gn/base/security/huks/
    mkdir -p ${D}/compiler_gn/base/security/huks/interfaces/innerkits/huks_standard/main/
    cp -rf ${WORKDIR}/security_huks/huks.bundle.json  ${D}/compiler_gn/base/security/huks/bundle.json
    cp -rf ${WORKDIR}/security_huks/huks.BUILD.gn ${D}/compiler_gn/base/security/huks/interfaces/innerkits/huks_standard/main/BUILD.gn
    cp -rf ${WORKDIR}/${pkg-huks}/hisysevent.yaml ${D}/compiler_gn/base/security/huks/
}

SYSROOT_DIRS += "${bindir} /compiler_gn"