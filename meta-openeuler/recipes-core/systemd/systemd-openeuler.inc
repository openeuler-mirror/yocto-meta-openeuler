LIC_FILES_CHKSUM = "file://${WORKDIR}/systemd-${PV}/LICENSE.GPL2;md5=751419260aa954499f7abaabaa882bbe \
                    file://${WORKDIR}/systemd-${PV}/LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c"


# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            git://github.com/systemd/systemd-stable.git;protocol=https;branch=${SRCBRANCH} \
            file://0001-binfmt-Don-t-install-dependency-links-at-install-tim.patch \
            file://0003-implment-systemd-sysv-install-for-OE.patch \
            file://0001-systemd.pc.in-use-ROOTPREFIX-without-suffixed-slash.patch \
            file://0001-logind-Restore-chvt-as-non-root-user-without-polkit.patch \
            file://0027-proc-dont-trigger-mount-error-with-invalid-options-o.patch \
            file://0001-analyze-resolve-executable-path-if-it-is-relative.patch \
            file://0001-sd-dhcp-client-check-error-earlier-and-reduce-indent.patch \
            file://0002-sd-dhcp-client-shorten-code-a-bit.patch \
            file://0003-sd-dhcp-client-logs-when-dhcp-client-unexpectedly-ga.patch \
            file://0004-sd-dhcp-client-tentatively-ignore-FORCERENEW-command.patch \
            file://0001-basic-unit-name-do-not-use-strdupa-on-a-path.patch \
            "
# files, patches that come from openeuler
SRC_URI =+ " \
        file://systemd-${PV}.tar.gz \
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
        file://journal-don-t-enable-systemd-journald-audit.socket-b.patch \
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
        file://print-the-real-reason-for-link-update.patch \
        file://core-skip-change-device-to-dead-in-manager_catchup-d.patch \
        file://revert-rpm-restart-services-in-posttrans.patch \
        file://Don-t-set-AlternativeNamesPolicy-by-default.patch \
        file://backport-core-fix-free-undefined-pointer-when-strdup-failed-i.patch \
        file://backport-fix-ConditionDirectoryNotEmpty-when-it-comes-to-a-No.patch \
        file://backport-fix-ConditionPathIsReadWrite-when-path-does-not-exis.patch \
        file://backport-fix-DirectoryNotEmpty-when-it-comes-to-a-Non-directo.patch \
        file://backport-CVE-2021-3997-rm-rf-refactor-rm_rf_children-split-out-body-of-dire.patch \
        file://backport-CVE-2021-3997-rm-rf-optionally-fsync-after-removing-directory-tree.patch \
        file://backport-CVE-2021-3997-tmpfiles-st-may-have-been-used-uninitialized.patch \
        file://backport-CVE-2021-3997-shared-rm_rf-refactor-rm_rf_children_inner-to-shorte.patch \
        file://backport-CVE-2021-3997-shared-rm_rf-refactor-rm_rf-to-shorten-code-a-bit.patch \
        file://backport-CVE-2021-3997-shared-rm-rf-loop-over-nested-directories-instead-of.patch \
        file://backport-fix-CVE-2021-33910.patch \
        file://backport-temporarily-disable-test-seccomp.patch \
        file://backport-revert-core-map-io.bfq.weight-to-1.1000.patch \
        file://backport-core-cgroup-fix-error-handling-of-cg_remove_xattr.patch \
        file://backport-core-wrap-cgroup-path-with-empty_to_root-in-log-mess.patch \
        file://backport-Bump-the-max-number-of-inodes-for-dev-to-a-million.patch \
        file://backport-Bump-the-max-number-of-inodes-for-tmp-to-a-million-t.patch \
        file://backport-unit-escape.patch \
        file://backport-udev-rename-type-name-e.g.-struct-worker-Worker.patch \
        file://backport-udev-run-the-main-process-workers-and-spawned-comman.patch \
        file://backport-timesync-fix-wrong-type-for-receiving-timestamp-in-n.patch \
        file://backport-udev-fix-potential-memleak.patch \
        file://backport-journalctl-never-fail-at-flushing-when-the-flushed-f.patch \
        file://backport-core-fix-SIGABRT-on-empty-exec-command-argv.patch \
        file://backport-core-service-also-check-path-in-exec-commands.patch \
        file://backport-Add-meson-option-to-disable-urlify.patch \
        file://backport-logind.conf-Fix-name-of-option-RuntimeDirectoryInode.patch \
        file://backport-unit-coldplug-both-job-and-nop_job-if-possible.patch \
        file://backport-meson.build-change-operator-combining-bools-from-to-.patch \
        file://backport-Avoid-tmp-being-mounted-as-tmpfs-without-the-user-s-.patch \
        file://backport-core-replace-slice-dependencies-as-they-get-added.patch \
        file://backport-journal-Only-move-to-objects-when-necessary.patch \
        file://backport-scsi_id-retry-inquiry-ioctl-if-host_byte-is-DID_TRAN.patch \
        file://backport-revert-units-add-ProtectClock-yes.patch \
"
