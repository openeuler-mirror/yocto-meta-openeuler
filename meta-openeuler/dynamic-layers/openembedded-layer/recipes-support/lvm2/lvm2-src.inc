# use src-openEuler package

# adapt 0005-do-not-build-manual.patch for 2.03.14 version
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

OPENEULER_REPO_NAME = "lvm2"

DEPENDS += "libaio"

PV = "2.03.14"

OPENEULER_SRC_URI_REMOVE = "git"

# remove open_embedded patch that not use
SRC_URI_remove = "file://0002-Guard-use-of-mallinfo-with-__GLIBC__.patch \
            file://0006-start-lvm2-monitor.service-after-tmp.mount.patch \
"

SRC_URI_prepend = "file://LVM2.${PV}.tgz \
            file://0001-lvm2-set-default-preferred_names.patch \
            file://0002-lvm2-default-allow-changes-with-duplicate-pvs.patch \
            file://0003-devs-check-for-no-dev-when-dropping-aliases.patch \
            file://0004-bugfix-lvm2-add-SSD.patch \
            file://0005-bugfix-add-timeout-when-fail-to-wait-udev.patch \
            file://0006-bugfix-fix-the-code-maybe-lead-to-buffer-over-bound-access.patch \
            file://0007-enhancement-modify-default-log-level-to-error-level.patch \
            file://0008-enhancement-add-dfx-log.patch \
            file://0009-enhancement-syslog-more-when-use-libdevmapper-so.patch \
            file://0010-enhancement-log-it-when-disk-slow.patch \
            file://0011-bugfix-lvm2-fix-the-reuse-of-va_list.patch \
            file://0012-13-dm-disk.rules-check-DM_NAME-before-create-symlink.patch \
            file://0013-dev_name-determine-whether-the-dev-aliases-linked-li.patch \
            file://0014-lvm-code-reduce-cyclomatic-complexity.patch \
            file://0015-devices-file-move-clean-up-after-command-is-run.patch \
            file://0016-toollib-fix-segfault-when-handling-selection-with-hi.patch \
            file://0017-Move-nolocking-warning-to-man-page.patch \
            file://0018-fix-args-entry-for-nolocking.patch \
            file://0019-dmsetup-check-also-for-ouf-of-range-value.patch \
            file://0020-toollib-do-not-process-just-created-historical-LV.patch \
            file://0021-pvscan-match-device-arg-to-filter-symlink.patch \
            file://0022-pvscan-fix-filter-symlink-checks.patch \
            file://0023-udev-repeat.patch \
            file://0024-use-sync-io-read-bcache-by-defaults.patch \
            file://0025-vgremove-PVID-file-leakage-in-run-lvm-pvs_online.patch \
            file://0026-lvmcache-fix-valgrind-error-when-dropping-md-duplica.patch \
            file://0027-toollib-fix-segfault-if-using-S-select-with-log-repo.patch \
            file://0028-pvscan-use-alternate-device-names-from-DEVLINKS-to-c.patch \
            file://0029-vgchange-acquire-an-exclusive-VG-lock-for-refresh.patch \
            file://0030-udev-create-symlinks-and-watch-even-in-suspended-sta.patch \
            file://0031-udev-import-previous-results-of-blkid-when-in-suspen.patch \
            file://0032-clean-up-group-struct-in-_stats_create_group-error-path.patch \
            file://0033-dm-event-release-buffer-on-dm_event_get_version.patch \
" 

SRC_URI[sha256sum] = "4a63bc8a084a8ae3c7bc5e6530cac264139d218575c64416c8b99e3fe039a05c"

S = "${WORKDIR}/LVM2.${PV}"
