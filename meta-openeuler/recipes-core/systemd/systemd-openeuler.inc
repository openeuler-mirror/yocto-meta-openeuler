
FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/systemd:"

# systemd patches in openEuler Embedded come from three places:
#   A. upstream fixes backported by openEuler (src-openeuler systemd.spec
#      Patch6001 - Patch6007)
#   B. openEuler specific patches (src-openeuler systemd.spec Patch9xxx)
#   C. openEuler Embedded adaptation patches shipped by this layer
#
# Patches are applied top to bottom, so the listing order must be preserved.
# A patch is only dropped when it does not fix a real defect and is not
# required by the Yocto/openEuler Embedded build; the reason is documented
# next to the affected patch below or in systemd_%.bbappend.

# openEuler source tarball; the recipe sets S to its extracted directory.
SYSTEMD_OE_PATCHES = " \
        file://systemd-${PV}.tar.gz \
"

# --- Group A: backported upstream fixes (src-openeuler Patch6001 - Patch6007) ---
SYSTEMD_OE_PATCHES += " \
        file://backport-Revert-sysctl.d-switch-net.ipv4.conf.all.rp_filter-f.patch \
        file://backport-Avoid-tmp-being-mounted-as-tmpfs-without-the-user-s-.patch \
        file://backport-temporarily-disable-test-seccomp.patch \
        file://backport-sd-event-always-initialize-sd_event.perturb.patch \
        file://backport-sd-event-fix-error-handling.patch \
        file://backport-core-refuse-dbus-activation-if-dbus-is-not-running.patch \
        file://backport-core-only-refuse-Type-dbus-service-enqueuing-if-dbus.patch \
"

# --- Group B: openEuler specific patches (src-openeuler Patch9xxx) ---
SYSTEMD_OE_PATCHES += " \
        file://udev-add-actions-while-rename-netif-failed.patch \
        file://fix-two-VF-virtual-machines-have-same-mac-address.patch \
"

# Refreshed locally against systemd 253 to remove a patch-fuzz warning; the
# refreshed copy in files/ shadows the src-openeuler one (FILESEXTRAPATHS).
SYSTEMD_OE_PATCHES += " \
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
"

# Patch9029 (disable-initialize_clock.patch) is intentionally not applied:
# openEuler keeps it only for sw_64 and reverts it on every other arch
# ("%ifnarch sw_64 %patch9029 -R -p1" in systemd.spec). openEuler Embedded
# does not support sw_64, so dropping it matches openEuler behaviour.
SYSTEMD_OE_PATCHES += " \
        file://systemd-solve-that-rsyslog-reads-journal-s-object-of.patch \
        file://check-whether-command_prev-is-null-before-assigning-.patch \
        file://revert-rpm-restart-services-in-posttrans.patch \
        file://Don-t-set-AlternativeNamesPolicy-by-default.patch \
        file://change-NTP-server-to-x.pool.ntp.org.patch \
        file://keep-weight-consistent-with-the-set-value.patch \
"

# Kept to stay aligned with openEuler, which applies it on every architecture;
# the added code is guarded by __sw_64__ and is inert on aarch64.
SYSTEMD_OE_PATCHES += " \
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

# SRC_URI =+ prepends, so the whole openEuler list stays ahead of the patches
# pulled in from systemd.inc / systemd_253.7.bb, matching the previous order.
SRC_URI =+ "${SYSTEMD_OE_PATCHES}"

# --- Group C: openEuler Embedded adaptation patches (this layer) ---
# openEuler ships update-rtc-with-system-clock-when-shutdown.patch, but it
# does not work for embedded's current needs: embedded's "base_dir" is "/bin"
# instead of "/usr/bin". The local copy in files/ therefore shadows the
# src-openeuler one (FILESEXTRAPATHS) and is the version that gets applied.
SRC_URI += " \
        file://update-rtc-with-system-clock-when-shutdown.patch \
"
