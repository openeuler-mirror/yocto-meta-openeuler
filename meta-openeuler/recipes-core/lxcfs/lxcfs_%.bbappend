PV = "4.0.11"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-systemd.patch \
        file://0002-remove-sysvinit-upstart.patch \
        file://0003-show-dev-name-in-container.patch \
        file://0004-lxcfs-fix-cpuinfo-print.patch \
        file://0005-fix-memory-leak.patch \
        file://0006-fix-concurrency-problem.patch \
        file://0007-set-null-after-free.patch \
        file://0008-fix-hang.patch \
        file://0009-limit-stat-by-quota-period-setting.patch \
        file://0010-diskstats-support-devicemapper-device.patch \
        file://0011-lxcfs-add-proc-partitions.patch \
        file://0012-lxcfs-proc_diskstats_read-func-obtain-data-from-blki.patch \
        file://0013-add-secure-compile-option-in-Makefile.patch \
        file://0014-fix-proc-diskstats-show-in-container.patch \
        file://0015-lxcfs-adapt-4.18-kernel.patch \
        file://0016-remove-lxcfs-tools-dependency-for-common-use.patch \
        file://0017-proc_fuse-fix-wait-child-process-hang.patch \
        file://0018-fix-deadlock-problem-when-subprocess-exit.patch \
        file://0019-fix-dev-read-memory-leak-in-container.patch \
        file://0020-enable-cfs-option-to-show-correct-proc-cpuinfo-view.patch \
        file://0021-fix-pidfd_open-pidfd_send_signal-function-compilatio.patch \
        file://0022-cpuview-fix-possible-use-after-free-in-find_proc_sta.patch \
        file://0023-proc-fix-proc-diskstats-output-format.patch \
        file://0024-typofix-fix-incorrect-printing-in-lxcfs-help-interfa.patch \
"
