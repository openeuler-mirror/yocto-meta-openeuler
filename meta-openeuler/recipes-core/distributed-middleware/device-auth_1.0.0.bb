SUMMARY = "System ability manager"
DESCRIPTION = "OpenEuler supports device auth for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-device-auth = "security_device_auth-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "security_device_auth"

SRC_URI += " \
            file://security_device_auth;unpack=true \
            file://security_device_auth/0001-security_device_auth.patch;patchdir=${WORKDIR}/device_auth \
            file://security_device_auth/device_auth.bundle.json \
            file://security_device_auth/device_auth.BUILD.gn \
            "

DEPENDS += "hilog c-utils distributed-beget eventhandler ipc samgr safwk huks"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_unpack:append() {
    bb.build.exec_func('do_extract_device_auth_source', d)
}

do_extract_device_auth_source() {
    tar -oxf ${DL_DIR}/${pkg-device-auth}.tar.gz -C ${WORKDIR}/
}

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/base/security/device_auth/
    cp -rf ${WORKDIR}/device_auth/* ${S}/base/security/device_auth/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/device_auth/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    install -d -m 0755 ${D}/system/bin/
    # prepare head files
    find ${S}/out/openeuler/innerkits/linux-arm64/device_auth/ -name *.h -print0 | xargs -0 -i cp -rf {} ${D}/${includedir}/device_auth/
    # copy executable file.
    install -m 0755 ${S}/out/openeuler/packages/phone/system/bin/deviceauth_service ${D}/${bindir}/
    ln -s ../../${bindir}/deviceauth_service ${D}/system/bin/deviceauth_service
    # prepare so
    install -m 0755 ${S}/out/openeuler/linux_arm64/security/device_auth/*.so ${D}/${libdir}/

    # copy bundle
    mkdir -p ${D}/compiler_gn/base/security/device_auth/services/
    cp -rf ${WORKDIR}/security_device_auth/device_auth.bundle.json  ${D}/compiler_gn/base/security/device_auth/bundle.json
    cp -rf ${WORKDIR}/security_device_auth/device_auth.BUILD.gn ${D}/compiler_gn/base/security/device_auth/services/BUILD.gn
}

SYSROOT_DIRS += "${bindir} /compiler_gn"