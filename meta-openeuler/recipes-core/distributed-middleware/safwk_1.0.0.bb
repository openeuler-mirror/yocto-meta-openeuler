SUMMARY = "System ability manager"
DESCRIPTION = "OpenEuler supports samgr for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-safwk = "systemabilitymgr_safwk-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "systemabilitymgr_safwk"

SRC_URI += " \
            file://${pkg-safwk}.tar.gz \
            file://systemabilitymgr_safwk/0000-remove-dependency-on-hitrace-safwk.patch;patchdir=${WORKDIR}/safwk \
            file://systemabilitymgr_safwk/0001-feat-for-embedded-fix-config_safwk-include_dirs.patch;patchdir=${WORKDIR}/safwk \
            file://systemabilitymgr_safwk/start_services.sh \
            file://systemabilitymgr_safwk/stop_services.sh \
            file://systemabilitymgr_safwk/safwk.bundle.json \
            file://systemabilitymgr_safwk/innerkits.safwk.BUILD.gn \
            file://systemabilitymgr_safwk/services.safwk.BUILD.gn \
            "

SRC_URI:append = " \
        file://0003-feat-for-embedded-modify-language-in-start-script.patch;patchdir=${WORKDIR}/systemabilitymgr_safwk \
        file://0005-feat-for-embedded-modify-binder-check-conditions.patch;patchdir=${WORKDIR}/systemabilitymgr_safwk \
"

DEPENDS += "hilog c-utils distributed-beget eventhandler ipc samgr"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/foundation/systemabilitymgr/safwk/
    cp -rf ${WORKDIR}/safwk/* ${S}/foundation/systemabilitymgr/safwk/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=${is_clang} --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/safwk/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    install -d -m 0755 ${D}/system/bin/

    # prepare so
    install -m 0755 ${S}/out/openeuler/linux_*arm64/systemabilitymgr/safwk/*.so ${D}/${libdir}/
    # prepare bin
    install -m 0755 ${S}/out/openeuler/linux_*arm64/systemabilitymgr/safwk/sa_main ${D}/${bindir}/
    ln -s ../../${bindir}/sa_main ${D}/system/bin/sa_main

    install -m 0755 ${WORKDIR}/systemabilitymgr_safwk/start_services.sh ${D}/system/bin/
    install -m 0755 ${WORKDIR}/systemabilitymgr_safwk/stop_services.sh ${D}/system/bin/
    # prepare head files
    install -m 554 ${S}/foundation/systemabilitymgr/safwk/services/safwk/include/*.h ${D}/${includedir}/safwk/
    install -m 554 ${S}/foundation/systemabilitymgr/safwk/interfaces/innerkits/safwk/*.h ${D}/${includedir}/safwk/

    # copy bundle
    mkdir -p ${D}/compiler_gn/foundation/systemabilitymgr/safwk/interfaces/innerkits/safwk/
    mkdir -p ${D}/compiler_gn/foundation/systemabilitymgr/safwk/services/safwk/
    cp -rf ${WORKDIR}/systemabilitymgr_safwk/safwk.bundle.json  ${D}/compiler_gn/foundation/systemabilitymgr/safwk/bundle.json
    cp -rf ${WORKDIR}/systemabilitymgr_safwk/innerkits.safwk.BUILD.gn ${D}/compiler_gn/foundation/systemabilitymgr/safwk/interfaces/innerkits/safwk/BUILD.gn
    cp -rf ${WORKDIR}/systemabilitymgr_safwk/services.safwk.BUILD.gn ${D}/compiler_gn/foundation/systemabilitymgr/safwk/services/safwk/BUILD.gn
}

SYSROOT_DIRS += "${bindir} /compiler_gn"
