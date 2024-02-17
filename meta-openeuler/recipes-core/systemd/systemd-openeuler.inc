
FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/systemd:"

# files, patches that come from openeuler
SRC_URI =+ " \
        file://systemd-${PV}.tar.gz \
        file://backport-Revert-sysctl.d-switch-net.ipv4.conf.all.rp_filter-f.patch \
        file://backport-Avoid-tmp-being-mounted-as-tmpfs-without-the-user-s-.patch \
        file://backport-temporarily-disable-test-seccomp.patch \
        file://backport-sd-event-always-initialize-sd_event.perturb.patch \
        file://backport-sd-event-fix-error-handling.patch \
        file://backport-core-refuse-dbus-activation-if-dbus-is-not-running.patch \
        file://backport-core-only-refuse-Type-dbus-service-enqueuing-if-dbus.patch \
        file://update-rtc-with-system-clock-when-shutdown.patch \
        file://udev-add-actions-while-rename-netif-failed.patch \
        file://fix-two-VF-virtual-machines-have-same-mac-address.patch \
        file://logind-set-RemoveIPC-to-false-by-default.patch \
        file://rules-add-rule-for-naming-Dell-iDRAC-USB-Virtual-NIC.patch \
        file://unit-don-t-add-Requires-for-tmp.mount.patch \
        file://rules-add-elevator-kernel-command-line-parameter.patch \
        file://rules-add-the-rule-that-adds-elevator-kernel-command.patch \
        file://units-add-Install-section-to-tmp.mount.patch \
        file://Make-systemd-udevd.service-start-after-systemd-remou.patch \
        file://udev-virsh-shutdown-vm.patch \
        file://sd-bus-properly-initialize-containers.patch \
        file://Revert-core-one-step-back-again-for-nspawn-we-actual.patch \
        file://systemd-change-time-log-level.patch \
        file://fix-capsh-drop-but-ping-success.patch \
        file://resolved-create-etc-resolv.conf-symlink-at-runtime.patch \
        file://pid1-bump-DefaultTasksMax-to-80-of-the-kernel-pid.ma.patch \
        file://fix-journal-file-descriptors-leak-problems.patch \
        file://activation-service-must-be-restarted-when-reactivated.patch \
        file://systemd-core-fix-problem-of-dbus-service-can-not-be-started.patch \
        file://delay-to-restart-when-a-service-can-not-be-auto-restarted.patch \
        file://disable-initialize_clock.patch \
        file://systemd-solve-that-rsyslog-reads-journal-s-object-of.patch \
        file://check-whether-command_prev-is-null-before-assigning-.patch \
        file://revert-rpm-restart-services-in-posttrans.patch \
        file://Don-t-set-AlternativeNamesPolicy-by-default.patch \
        file://change-NTP-server-to-x.pool.ntp.org.patch \
        file://keep-weight-consistent-with-the-set-value.patch \
        file://Systemd-Add-sw64-architecture.patch \
        file://core-update-arg_default_rlimit-in-bump_rlimit.patch \
        file://set-forwardtowall-no-to-avoid-emerg-log-shown-on-she.patch \
        file://core-cgroup-support-cpuset.patch \
        file://core-cgroup-support-freezer.patch \
        file://core-cgroup-support-memorysw.patch \
        file://systemd-core-Add-new-rules-for-lower-priority-events.patch \
        file://bugfix-also-stop-machine-when-a-machine-un.patch \
        file://print-the-process-status-to-console-when-shutdown.patch \
        file://Retry-to-handle-the-uevent-when-worker-is-terminated.patch \
        file://treat-hyphen-as-valid-hostname-char.patch \
        file://process-util-log-more-information-when-runnin.patch \
        file://fuser-print-umount-message-to-reboot-umount-msg.patch \
        file://shutdown-reboot-when-recieve-crash-signal.patch \
        file://core-add-OptionalLog-to-allow-users-change-log-level.patch \
        file://core-cgroup-support-default-slice-for-all-uni.patch \
        file://core-add-invalidate-cgroup-config.patch \
        file://let-the-child-of-one-unit-don-t-affect-each-other.patch \
        file://support-disable-cgroup-controllers-we-don-t-want.patch \
        file://bugfix-for-cgroup-Swap-cgroup-v1-deletion-and-migration.patch \
        file://delete-journal-files-except-system.journal-when-jour.patch \
        file://set-the-cpuset.cpus-mems-of-machine.slice-to-all-by-.patch \
"
