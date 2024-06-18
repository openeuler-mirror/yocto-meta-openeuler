SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

OPENEULER_REPO_NAME = "iSulad"

# file and patches from openEuler
SRC_URI = " \
        file://v${PV}.tar.gz \
        file://0001-code-improve-for-sandbox.cc.patch \
        file://0002-fix-compile-error-with-protobuf-25.1-and-grpc-1.60.x.patch \
        file://0003-bugfix-for-mount-point-remains-under-special-circums.patch \
        file://0004-do-not-cleanup-if-the-directory-does-not-exist.patch \
        file://0005-module-only-deletes-the-temporary-files-it-creates.patch \
        file://0006-skip-devmapper-ut.patch \
        file://0007-update-annotations-and-add-ci-cases.patch \
        file://0008-bug-fix-for-device-cgroup-ulimt-oci-update.patch \
        file://0009-improve-dt-for-oci-spec-update.patch \
        file://0010-open-run-container-with-dev-volume-testcase.patch \
        file://0011-add-cpu-usage-nano-cores-for-sandbox.patch \
        file://0012-sleep-some-time-in-ServiceWorkThread-to-prevent-the-.patch \
        file://0013-restore-name-for-rename-failed.patch \
        file://0014-2371-Allow-iSulad-to-pull-load-image-with-symlink.patch \
        file://0015-Replace-http-parser-dependency-with-lcr.patch \
        file://0016-add-more-detailed-log-information-for-load-sandbox.patch \
        file://0017-bugfix-for-the-concurrency-competition-between-the-r.patch \
        file://0018-add-concurrent-load-test.patch \
        file://0019-get-the-realpath-of-the-host-path-for-archive-when-c.patch \
        file://0020-bugfix-for-wrong-goto-branch.patch \
        file://0021-bugfix-for-wrong-dynamic-allocation-object-type.patch \
        file://0022-add-swap-usage-in-cri.patch \
        file://0023-add-benchmark-result-of-perf-test-in-cri.patch \
        file://0024-add-support-for-systemd-cgroup-driver.patch \
        file://0025-add-ci-cases-for-systemd-cgroup-driver.patch \
        file://0026-move-systemd_cgroup-CI-test-to-manual-cases.patch \
        file://0027-feature-add-support-for-cgroup-v2-metrics.patch \
        file://0028-use-supervisor-to-notify-sandbox-exit-event.patch \
        file://0029-refactor-cgroup-module.patch \
        file://0030-adaptor-unit-test-for-cgroup-module.patch \
        file://0031-cgroup-v2-does-not-support-isulad-setting-cpu_rt-opt.patch \
        file://0032-add-test-that-isulad-cannot-set-cpu_rt-parameters-wh.patch \
        file://0033-fix-sandbox-container-bool-value-uninitialized.patch \
        file://0034-bugfix-for-cpurt.sh.patch \
        file://0035-monitor-cgroup-oom-killed-event-and-update-to-cri-of.patch \
        file://0036-add-ci-cases-for-oomkilled-monitor.patch \
        file://0037-add-cgroup-v2-doc.patch \
        file://0038-add-modify-for-cgroup-v2-ci-test.patch \
        file://0039-fix-run-ubuntu-container-bug-in-inspect.sh.patch \
        file://0040-add-support-for-GetContainerEvents.patch \
        file://0041-fix-cpurt-init-bug-for-systemd-cgroup.patch \
        file://0042-fix-message-queue-concurrent-bug.patch \
        file://0043-specify-runtime-as-runc-for-oom-test-CI.patch \
        file://0044-set-oomkilled-in-cri.patch \
        file://0045-add-cri-1.29-update-design-doc.patch \
        file://0046-oom-monitor-in-manual-cases.patch \
        file://0047-add-usage-restrictions-for-CRI-1.29-update.patch \
        file://0048-CDI-interface-definition.patch \
        file://0049-distinguish-between-runtime-and-runtime_cmd-in-isula.patch \
        file://0050-Use-user-defined-shm-for-CRI-request.patch \
        file://0051-Fix-memory-leak-in-set_connected_container_shm_path.patch \
        file://0052-init-enable_pod_events-as-false.patch \
        file://0053-remove-container-root-path-in-rt_lcr_rm-if-lcr-runti.patch \
        file://0054-ensure-sandbox-can-be-removed-if-sandbox-container-r.patch \
        file://0055-bugfix-for-shim-timeout-exit-error-log-changes.patch \
        file://0056-bugfix-for-the-pre-created-pipe-was-not-closed-when-.patch \
        file://0057-add-debug-msg-info-in-image_load.sh.patch \
        file://0058-empty-pointer-check-in-lcr_rt_ops.patch \
        file://0059-modify-some-grpc-status-codes-of-cri-in-case-of-erro.patch \
        file://0060-cdi-return-int-instead-of-error-string.patch \
        file://0061-cdi-support-modules-operate-registry-annotations.patch \
        file://0062-do-not-umount-shmpath-for-sandbox-container.patch \
        file://0063-remove-default-systemd-cgroup-and-enable-cri-v1-valu.patch \
        file://0064-cdi-support-module-cache.patch \
        file://0065-change-default-subscribe-timeout-to-5min.patch \
        file://0066-cdi-support-modules-version-spec-spec_dirs-device.patch \
        file://0067-cdi-support-modules-container_edits-parser.patch \
        file://0068-cdi-invoke-cdi-operate-when-init-isulad-and-create-c.patch \
        file://0069-bugfix-fix-cni_operate_ut-ut.patch \
        file://0070-isolate-sandboxer-code-by-using-macro.patch \
        file://0071-Remove-sandboxer-ut-if-sandboxer-is-not-enabled.patch \
        file://0072-cdi-design-doc.patch \
        file://0073-bugfix-cdi-version-check.patch \
        file://0074-bugfix-of-background-execution-exec-error-command.patch \
        file://0075-bugfix-for-setting-cpu-rt-to-a-negative-value-when-e.patch \
        file://0076-cdi-add-UT.patch \
        file://0077-remove-extra-s-in-CreateContainerLogSymlink.patch \
        file://0078-allow-env-variable-has-an-empty-value.patch \
        file://0079-Fix-Failed-to-execute-image-pull-on-name-tag-digest-.patch \
        file://0080-bugfix-for-hostname-env-set-only-once.patch \
        file://0081-set-the-sandbox-status-to-not-ready-under-abnormal-c.patch \
        file://0082-fix-shim-controller-set-incorrect-sandbox-status-sta.patch \
        file://0083-fix-bug-for-invalid-env-write.patch \
        file://0084-trim-key-value-for-env.patch \
        file://0085-cdi-allow-env-variable-has-an-empty-value.patch \
        file://0086-cdi-test-case-and-gateway.patch \
        file://0087-code-improve.patch \
        file://0088-testcase-close-cdi-testcase.patch \
        file://0089-docs-update-cni-doc.patch \
        file://0090-modify-the-user-error-log-to-be-the-same-as-before.patch \
        file://0091-add-enable-cri-v1-in-k8s-integration.patch \
        file://0092-isolate-oom-monitor-codes.patch \
        file://0093-change-fork-process-exit-mode.patch \
        file://0094-fix-error-log-for-verify_cpu_realtime.patch \
        file://0095-bugfix-change-max-network-name-len.patch \
        file://0096-del-useless-info.patch \
        file://0097-code-improve.patch \
        file://0098-cdi-add-debug-info.patch \
        file://0099-bugfix-cni-network-name-UT.patch \
        file://0100-bugfix-malloc-right-type-size.patch \
        file://0101-use-isula_clean_path-rather-than-realpath.patch \
        file://0102-fix-false-engine-rootpath-reference.patch \
        file://0103-bugfix-add-note.patch \
        file://0104-bugfix-adapt-network-name-max-len.patch \
        file://0105-start-sandbox-before-setup-network-by-default.patch \
        file://0106-Revert-use-isula_clean_path-rather-than-realpath.patch \
        file://0107-bugfix-for-start-sandbox-before-setup-network-by-def.patch \
        file://0108-skip-test-rely-on-docker.io.patch \
"

# openEuler Embedded's modification
# 0001-configuration-use-lcr.patch: use lcr instead of runc
# config_cgroup: configure cgroups when the system does not use systemd
# isulad.service: systemd service file for isulad
SRC_URI:append = " \
        file://0001-configuration-use-lcr.patch \
        file://config_cgroup \
        file://isulad.service \
"

S = "${WORKDIR}/iSulad-v${PV}"

inherit cmake pkgconfig
OECMAKE_GENERATOR = "Unix Makefiles"

USE_PREBUILD_SHIM_V2 = "1"


DEPENDS += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux ncurses \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc grpc-native protobuf-native \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

RDEPENDS:${PN} += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux ncurses \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc \
        glibc-binary-localedata-en-us \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

EXTRA_OECMAKE = "-DENABLE_GRPC=ON -DENABLE_GRPC_REMOTE_CONNECT=OFF \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '-DENABLE_SYSTEMD_NOTIFY=ON', '-DENABLE_SYSTEMD_NOTIFY=OFF', d)} \
		-DENABLE_SHIM_V2=ON -DENABLE_OPENSSL_VERIFY=ON \
		-DGRPC_CONNECTOR=ON \
        -DENABLE_CRI_API_V1=ON \
        -DENABLE_CDI=ON \
        -DCMAKE_CXX_STANDARD=17 \
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

do_compile:prepend() {
    sed -i "10 a\# undef linux" ${WORKDIR}/build/grpc/src/api/services/cri/v1alpha/api.pb.h
    sed -i "10 a\# undef linux" ${WORKDIR}/build/grpc/src/api/services/cri/v1/api_v1.pb.h
}

DEPENDS += "update-rc.d-native"

do_install:append () {
    [[ "${libdir}" != "/usr/lib" ]] || return 0
    if test -d ${D}/usr/lib ; then
            install -d ${D}/${libdir}
            mv ${D}/usr/lib/* ${D}/${libdir}
            rm -rf ${D}/usr/lib/
    fi

    has_systemd="${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'True', 'False', d)}"
	# if the system uses systemd, manage isulad with it
	# the indentation of the word "EOF" is important, do not change it
	if [ $has_systemd = "True" ]; then
		install -d ${D}${sysconfdir}/systemd/system
		# create isulad.service file so systemd can manage isulad based on it
		if [ ! -e ${D}${sysconfdir}/systemd/system/isulad.service ]; then
            install -m 0644 ${WORKDIR}/isulad.service ${D}${sysconfdir}/systemd/system
		fi
	fi

    # if the os does not contain systemd, install init script configuring cgroups
    # because isulad needs cgroups to control resources
    if [ $has_systemd = "False" ]; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/config_cgroup ${D}${sysconfdir}/init.d
        # empower auto configuration of cgroups each time the system boots
        install -d ${D}${sysconfdir}/rcS.d
        update-rc.d -r ${D} config_cgroup start 99 5 .
    fi
}