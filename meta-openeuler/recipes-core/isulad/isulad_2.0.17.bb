SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSLv2"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

OPENEULER_REPO_NAME = "iSulad"

SRC_URI = "file://v${PV}.tar.gz \
           file://0001-use-epoll-instead-of-select-for-wait_exit_fifo.patch \
           file://0002-add-namespace-util-UT.patch \
           file://0003-refactor-build-system-of-cutils-ut.patch \
           file://0004-run-storage-layers-ut-with-non-root.patch \
           file://0005-add-extern-C-for-mainloop-header.patch \
           file://0006-add-UT-for-mainloop-and-network.patch \
           file://0007-add-check-for-aes-apis.patch \
           file://0008-add-ut-for-cutils-aes.patch \
           file://0009-add-ut-for-cutils-error.patch \
           file://0010-ensure-argument-is-not-null.patch \
           file://0011-add-ut-for-utils_fs.patch \
           file://0012-Add-adaptation-code-for-filters.patch \
           file://0013-Add-parameter-check-to-path.patch \
           file://0014-Add-ut-for-utils_convert.patch \
           file://0015-Add-ut-for-path.patch \
           file://0016-Add-ut-for-filters.patch \
           file://0017-add-static-for-unexport-function.patch \
           file://0018-add-ut-for-cutils-timestamp.patch \
           file://0019-fix-timestamp-ut-error.patch \
           file://0020-improve-code-in-utils_mount_spec.patch \
           file://0021-Add-ut-for-utils_mount_spec.patch \
           file://0022-Add-ut-for-utils_regex.patch \
           file://0023-improve-code-in-utils.c.patch \
           file://0024-add-ut-for-cutils-utils.patch \
           file://0025-make-sure-kill-pid-not-negative.patch \
           file://0026-add-UT-for-atomic-and-map.patch \
           file://0027-remove-unnecessary-goto-and-add-parameter-check-for-.patch \
           file://0028-Add-ut-for-verify.patch \
           file://0029-fix-error-in-utils_verify_ut.patch \
           file://0030-add-more-test-for-string-and-map.patch \
           file://0031-remove-mnt-point-if-add-device-mapper-device-failed.patch \
           file://0032-dec-device-info-ref-in-grow-device-fs.patch \
           file://0033-device-mapper-bugfix.patch \
           file://0034-delete-syncCloseSem-when-close-all-wssession.patch \
           file://0035-improve-debug-information-for-console-io.patch \
           file://0036-add-ut-for-file.patch \
           file://0037-Add-extend-C-for-header-files.patch \
           file://0038-add-isula-create-rm-option.patch \
           file://0039-feat-add-container-cleanup-module.patch \
           file://0040-bugfix-for-websocket-receive-data-too-long.patch \
           file://0041-fix-call-bim_put-in-im_get_rootfs_dir.patch \
           file://0042-isula-usage-consistency-optimization.patch \
           file://0043-fix-do-container_unref-in-oci_rootfs_clean.patch \
           file://0044-fix-can-not-install-isulad-rpm-because-of-spec.patch \
           file://0045-remove-unknown-option-wno-maybe-uninitialized.patch \
           file://0046-fix-storage-layer-and-driver-ut-failed-in-container.patch \
           file://0047-handle-security-warning-for-cleanup-module.patch \
           file://0048-add-unit-test-for-util-sha256.patch \
           file://0049-add-primary-group-to-additional-groups.patch \
           file://0050-add-unit-test-for-buffer.patch \
           file://0051-remove-chmod-751-permission-for-dirs-by-engine-when-.patch \
           file://0052-add-console-ut.patch \
           file://0053-fix-additional-gids-for-exec-user.patch \
           file://0054-add-CI-for-additional-gid.patch \
           file://0055-retry-call-runtime-ops.patch \
           file://0056-add-ut-test-for-retry-macro.patch \
           file://0057-1749-set-inspect_container-timeout.patch \
           file://0058-1757-add-adaption-code-for-musl.patch \
           file://0059-deleting-broken-rootfs.patch \
           file://0060-1761-fix-leftover-devicemapper-mnt-dir.patch \
           file://0061-check-file-system-ro-before-merge-network-for-syscon.patch \
           file://0062-isulad-shim-wait-for-all-child-process.patch \
           file://0063-When-run-options-rm-is-set-delete-the-stoped-contain.patch \
           file://0064-recheck-kill-command-exit-status.patch \
           file://0065-start-sandbox-before-setup-network-by-default.patch \
           file://0066-compatibility-for-manage-pods-which-created-by-old-i.patch \
           "

S = "${WORKDIR}/iSulad-v${PV}"

inherit cmake
OECMAKE_GENERATOR = "Unix Makefiles"

DEPENDS = "yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets lvm2"

EXTRA_OECMAKE = "-DENABLE_GRPC=OFF -DENABLE_SYSTEMD_NOTIFY=OFF -DENABLE_SELINUX=OFF \
		-DENABLE_SHIM_V2=OFF -DENABLE_OPENSSL_VERIFY=OFF \
		-DGRPC_CONNECTOR=OFF -DENABLE_OCI_IMAGE=ON \
		"

# The arm32 architecture does not currently support this option, so delete this option as a workaround
EXTRA_OECMAKE_remove_arm = "-DENABLE_OCI_IMAGE=ON"
EXTRA_OECMAKE_append_arm = " -DDISABLE_OCI=ON "

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
