SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSLv2"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

OPENEULER_REPO_NAME = "iSulad"

SRC_URI = "file://v${PV}.tar.gz \
           file://0001-modify-dependence-from-lcr-to-libisula.patch \
           file://0002-Add-unified-memory_swap_limit_in_bytes-fields-into-C.patch \
           file://0003-Add-macro-for-protoc-cmake.patch \
           file://0004-fix-design-typo.patch \
           file://0005-fix-cpu-rt-review-comments.patch \
           file://0006-fix-inspect.sh-failed.patch \
           file://0007-add-CRI-ContainerStats-Service.patch \
           file://0008-fix-isula-cpu-rt-CI.patch \
           file://0009-fix-cpu-rt-CI.patch \
           file://0010-fix-cpu-rt-CI.patch \
           file://0011-Bugfix-in-config-and-executor.patch \
           file://0012-fix-cpu-rt-disable-after-reboot-machine.patch \
           file://0013-fix-selinux_label_ut-timeout-and-add-timeout-for-all.patch \
           file://0014-add-retry-for-read-write.patch \
           file://0015-support-pull-image-with-digest.patch \
           file://0016-isulad-shim-support-execSync-with-timeout.patch \
           file://0017-Refine-the-commit-info.patch \
           file://0018-Refine-typo-of-word-container.patch \
           file://0019-cleancode-for-read-write.patch \
           file://0020-add-crictl-timeout-and-sync-for-CI.patch \
           file://0021-unlock-m_podsLock-if-new-failed.patch \
           file://0022-Update-CRI.patch \
           file://0023-add-cgroup-cpu-ut.patch \
           file://0024-remove-temp-variables.patch \
           file://0025-fix-read-member-error-from-struct.patch \
           file://0026-Fix-PR-runc.patch \
           file://0027-allow-the-paused-container-to-be-stopped.patch \
           file://0028-Refine.patch \
           file://0029-support-isula-update-when-runtime-is-runc.patch \
           file://0030-Refine-as-others-feedback.patch \
           file://0031-fix-CRI-SetupPod-and-TearDownPod-deadlock.patch \
           file://0032-remote-layer-store-demo.patch \
           file://0033-add-ci-for-remote-ro.patch \
           file://0034-change-sleep-to-usleep-to-avoid-lossing-of-accuracy.patch \
           file://0035-fix-compile-error-when-not-enable-remote-ro.patch \
           file://0036-adapt-to-repo-of-openeuler-url-changed.patch \
           file://0037-change-goto-branch.patch \
           file://0038-CI-not-enable-remote-ro-for-ut.patch \
           file://0039-use-auto-free-to-proc_t.patch \
           file://0040-modifying-cpurt-file-permissions.patch \
           file://0041-use-CURLOPT_XFERINFOFUNCTION-instead-of-deprecated-C.patch \
           file://0042-bugfix-remote-ro-try-add-or-remove-image-layer-twice.patch \
           file://0043-bugfix-can-t-delete-layers-under-dir-overlay-layers.patch \
"

SRC_URI_append = "file://compile-error-fix.patch"

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

RDEPENDS_${PN} += " \
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

# there are issues with building grpc on arm32 and riscv platforms.
DEPENDS_remove_arm = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS_${PN}_remove_arm = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE_remove_arm = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON -DGRPC_CONNECTOR=ON "
EXTRA_OECMAKE_append_arm = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF -DGRPC_CONNECTOR=OFF "

DEPENDS_remove_riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS_${PN}_remove_riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE_remove_riscv64 = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON -DGRPC_CONNECTOR=ON "
EXTRA_OECMAKE_append_riscv64 = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF -DGRPC_CONNECTOR=OFF "

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES_${PN} += "${libdir}/* "
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""

do_configure_prepend() {
        grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
        set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_install_append () {
        [[ "${libdir}" != "/usr/lib" ]] || return 0
        if test -d ${D}/usr/lib ; then
                install -d ${D}/${libdir}
                mv ${D}/usr/lib/* ${D}/${libdir}
                rm -rf ${D}/usr/lib/
        fi
}
