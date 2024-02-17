SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-systemd.patch \
        file://0002-show-dev-name-in-container.patch \
        file://0003-lxcfs-fix-cpuinfo-print.patch \
        file://0004-fix-memory-leak.patch \
        file://0005-fix-concurrency-problem.patch \
        file://0006-set-null-after-free.patch \
        file://0007-limit-stat-by-quota-period-setting.patch \
        file://0008-diskstats-support-devicemapper-device.patch \
        file://0009-lxcfs-add-proc-partitions.patch \
        file://0010-lxcfs-proc_diskstats_read-func-obtain-data-from-blki.patch \
        file://0011-add-secure-compile-option-in-meson.patch \
        file://0012-lxcfs-adapt-4.18-kernel.patch \
        file://0013-enable-cfs-option-to-show-correct-proc-cpuinfo-view.patch \
        file://0014-fix-pidfd_open-pidfd_send_signal-function-compilatio.patch \
        file://0015-adapt-meson-build-install.patch \
"

SRC_URI:append = " \
	file://systemd-ensure-var-lib-lxcfs-exists.patch \
"
