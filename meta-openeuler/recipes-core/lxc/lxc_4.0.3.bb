SUMMARY = "Protocol Buffers - structured data serialisation mechanism"
DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
SECTION = "console/tools"
LICENSE = "BSD-2-Clause"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://lxc/lxc-4.0.3.tar.gz \
           file://lxc/0001-huawei-adapt-to-huawei-4.0.3.patch \
	  file://lxc/0002-add-mount-label-for-rootfs.patch \
	  file://lxc/0003-format-code-and-verify-mount-mode.patch \
	  file://lxc/0004-Removes-the-definition-of-the-thread-attributes-obje.patch \
          file://lxc/0005-solve-coredump-bug-caused-by-fstype-being-NULL-durin.patch \
	  file://lxc/0006-SIGTERM-do-not-catch-signal-SIGTERM-in-lxc-monitor.patch \
	  file://lxc/0007-Using-string-type-instead-of-security_context_t-beca.patch \
	  file://lxc/0008-hook-pass-correct-mount-dir-as-root-to-hook.patch \
	  file://lxc/0009-cgroup-refact-cgroup-manager-to-single-file.patch \
	  file://lxc/0010-cgfsng-adjust-log-level-from-error-to-warn.patch \
	  file://lxc/0011-rootfs-add-make-private-for-root.path-parent.patch \
	  file://lxc/0012-mount-make-possible-to-bind-mount-proc-and-sys-fs.patch \
	  file://lxc/0013-use-path-based-unix-domain-sockets-instead-of-abstra.patch \
          file://lxc/0014-api-add-get-container-metrics-api.patch \
	  file://lxc/0015-Streaming-IO-solution-optimization-and-enhancement.patch \
	  file://lxc/0016-avoid-using-void-pointers-in-caclulation.patch \
	  file://lxc/0017-fix-compilation-errors-without-libcap.patch \
	  file://lxc/0018-IO-fix-io-data-miss-when-exec-with-pipes.patch \
	  file://lxc/0019-metrics-add-total_inactive_file-metric-for-memory.patch \
	  file://lxc/0020-support-cgroup-v2.patch \
          file://lxc/0021-support-isula-exec-workdir.patch \
	  file://lxc/0022-print-error-message-if-process-workdir-failed.patch \
	  file://lxc/0023-log-support-long-syslog-tag.patch \
	  file://lxc/0024-log-adjust-log-level-from-error-to-warn.patch \
	  file://lxc/0025-get-cgroup-data-len-first-and-malloc-read-buff-by-le.patch \
          file://lxc/0026-coredump-fix-coredump-when-cgroup-get-return-error.patch \
          file://lxc/0027-add-help-for-new-arguments.patch \
          file://lxc/0028-seccomp-init-and-destroy-notifier.cookie.patch \
          file://lxc/0029-just-use-origin-loop-if-do-not-have-io.patch \
          file://lxc/0030-conf-fix-a-memory-leak.patch \
          file://lxc/0031-fix-lsm_se_mount_context-memory-leak.patch \
          file://lxc/0032-disable-lxc_keep-with-oci-image.patch \
          file://lxc/0033-conf-ensure-that-the-idmap-pointer-itself-is-freed.patch \
          file://lxc/0034-cgfsng-fix-cgroup-attach-cgroup-creation.patch \
	  file://support_arm32.patch \
	  file://check_only_rootfs_as_filesystem_type.patch \
	"


DEPENDS = "yajl libseccomp libcap"

S = "${WORKDIR}/${BPN}-${PV}"

EXTRA_OECONF = "--disable-static --disable-openssl --with-rootfs-path=/var/lib/lxc/rootfs --with-distro=openeuler"

inherit autotools

BBCLASSEXTEND = "native nativesdk"

CFLAGS_append = "-Wno-error=stringop-overflow -Wno-error=strict-prototypes -Wno-error=old-style-definition"
