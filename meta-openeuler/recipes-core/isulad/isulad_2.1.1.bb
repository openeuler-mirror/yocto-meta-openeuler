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

    has_systemd="${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'True', 'False', d)}"
	# if the system uses systemd, manage isulad with it
	# the indentation of the word "EOF" is important, do not change it
	if [ $has_systemd = "True" ]; then
		install -d ${D}${sysconfdir}/systemd/system
		# create isulad.service file so systemd can manage isulad based on it
		if [ ! -e ${D}${sysconfdir}/systemd/system/isulad.service ]; then
			cat <<-'EOF' >> ${D}${sysconfdir}/systemd/system/isulad.service
			[Unit]
			Description=isulad container daemon
			After=network.target

			[Service]
			ExecStart=/usr/bin/isulad

			[Install]
			WantedBy=multi-user.target
EOF
		fi
	fi

    # if the os does not contain systemd, install init script configuring cgroups
    # because isulad needs cgroups to control resources
    if [ $has_systemd = "False" ]; then
        install -d ${D}${sysconfdir}/init.d
        cat <<-'EOF' >> ${D}${sysconfdir}/init.d/config_cgroup
        #!/bin/sh
        ### BEGIN INIT INFO
        # Provides:          config_cgroup
        # Required-Start:    
        # Required-Stop:
        # Default-Start:     S
        # Default-Stop:
        ### END INIT INFO
        mount -t tmpfs tmpfs /sys/fs/cgroup/
        mkdir -p /sys/fs/cgroup/cpu
        mount -t cgroup -o cpu cpu /sys/fs/cgroup/cpu
        mkdir -p /sys/fs/cgroup/devices
        mount -t cgroup -o devices devices /sys/fs/cgroup/devices
        mkdir -p /sys/fs/cgroup/freezer
        mount -t cgroup -o freezer freezer /sys/fs/cgroup/freezer
        mkdir -p /sys/fs/cgroup/cpuset
        mount -t cgroup -o cpuset cpuset /sys/fs/cgroup/cpuset
        mkdir -p /sys/fs/cgroup/memory
        mount -t cgroup -o memory memory /sys/fs/cgroup/memory
        echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
        mkdir -p /sys/fs/cgroup/hugetlb
        mount -t cgroup -o hugetlb hugetlb /sys/fs/cgroup/hugetlb
        mkdir -p /sys/fs/cgroup/blkio
        mount -t cgroup -o blkio blkio /sys/fs/cgroup/blkio
EOF
        chmod 755 ${D}${sysconfdir}/init.d/config_cgroup
        # empower auto configuration of cgroups each time the system boots
        install -d ${D}${sysconfdir}/rcS.d
        ln -s ${sysconfdir}/init.d/config_cgroup ${D}${sysconfdir}/rcS.d/S99config_cgroup
    fi
}

python () {
    if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d):
        # FILES_${PN} cannot be automatically expanded
        pn = d.getVar('PN', True)
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/systemd/system/isulad.service')
    else:
        pn = d.getVar('PN', True)
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/init.d/config_cgroup')
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/rcS.d/S99config_cgroup')
}
