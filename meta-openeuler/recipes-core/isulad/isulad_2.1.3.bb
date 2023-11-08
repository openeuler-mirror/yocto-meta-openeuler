SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

OPENEULER_REPO_NAME = "iSulad"

SRC_URI = " \
        file://v${PV}.tar.gz \
        file://0001-2155-Use-reference-in-loop-in-listpodsandbox.patch \
        file://0002-2156-Fix-sandbox-error-logging.patch \
        file://0003-2158-Use-crictl-v1.22.0-for-ci.patch \
        file://0004-2162-Fix-rename-issue-for-id-manager.patch \
        file://0005-2163-add-bind-mount-file-lock.patch \
        file://0006-2168-fix-code-bug.patch \
        file://0007-2171-Fix-nullptr-in-src-daemon-entry.patch \
        file://0008-Add-vsock-support-for-exec.patch \
        file://0009-remove-unneccessary-strerror.patch \
        file://0010-do-not-report-low-level-error-to-user.patch \
        file://0011-remove-usage-of-strerror-with-user-defined-errno.patch \
        file://0012-use-gmtime_r-to-replace-gmtime.patch \
        file://0013-improve-report-error-message-of-client.patch \
        file://0014-adapt-new-error-message-for-isula-cp.patch \
        file://0015-2182-Add-mutex-for-container-list-in-sandbox.patch \
        file://0016-2180-fix-execlp-not-enough-args.patch \
        file://0017-2135-modify-incorrect-variable-type.patch \
        file://0018-make-sure-the-input-parameter-is-not-empty-and-optim.patch \
        file://0019-remove-password-in-url-module-and-clean-sensitive-in.patch \
        file://0020-2153-fix-codecheck.patch \
        file://0021-2157-bugfix-for-memset.patch \
        file://0022-2159-use-macros-to-isolate-the-password-option-of-lo.patch \
        file://0023-2161-bugfix-for-api-cmakelist.patch \
        file://0024-2165-preventing-the-use-of-insecure-isulad-tmpdir-di.patch \
        file://0025-2166-move-ensure_isulad_tmpdir_security-function-to-.patch \
        file://0026-2169-using-macros-to-isolate-isulad-s-enable_plugin-.patch \
        file://0027-2178-clean-path-for-fpath-and-verify-chain-id.patch \
        file://0028-2179-modify-the-permissions-of-tmpdir-and-file-lock-.patch \
        file://0029-image-ensure-id-of-loaded-and-pulled-image-is-valid.patch \
        file://0030-mask-proxy-informations.patch \
        file://0031-add-testcase-for-isula-info.patch \
        file://0032-fix-oci-import-compile-error.patch \
        file://0033-2188-Support-both-C-11-and-C-17.patch \
        file://0034-add-config-for-enable-cri-v1.patch \
"

S = "${WORKDIR}/iSulad-v${PV}"

inherit cmake
OECMAKE_GENERATOR = "Unix Makefiles"

USE_PREBUILD_SHIM_V2 = "1"


DEPENDS += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc grpc-native protobuf-native \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

RDEPENDS:${PN} += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc \
        glibc-binary-localedata-en-us \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

EXTRA_OECMAKE = "-DENABLE_GRPC=ON \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '-DENABLE_SYSTEMD_NOTIFY=ON', '-DENABLE_SYSTEMD_NOTIFY=OFF', d)} \
		-DENABLE_SHIM_V2=ON -DENABLE_OPENSSL_VERIFY=ON \
		-DGRPC_CONNECTOR=ON \
		"

# lib-shim-v2 depends on rust which is not well supported for arm32 and riscv64
# there are issues with building grpc on arm32 and riscv platforms.
DEPENDS:remove:arm = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS:${PN}:remove:arm = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE:remove:arm = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON -DGRPC_CONNECTOR=ON "
EXTRA_OECMAKE:append:arm = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF -DGRPC_CONNECTOR=OFF "

DEPENDS:remove:riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS:${PN}:remove:riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE:remove:riscv64 = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON -DGRPC_CONNECTOR=ON "
EXTRA_OECMAKE:append:riscv64 = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF -DGRPC_CONNECTOR=OFF "

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES:${PN} += "${libdir}/* "
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""

do_configure:prepend() {
        grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
        set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_install:append () {
        [[ "${libdir}" != "/usr/lib" ]] || return 0
        if test -d ${D}/usr/lib ; then
                install -d ${D}/${libdir}
                mv ${D}/usr/lib/* ${D}/${libdir}
                rm -rf ${D}/usr/lib/
        fi
}
