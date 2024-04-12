# use src-openEuler package

# adapt 0005-do-not-build-manual.patch for 2.03.14 version
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

OPENEULER_REPO_NAME = "lvm2"

DEPENDS += "libaio"

PV = "2.03.21"

# remove open_embedded patch that not use
SRC_URI:remove = "file://0002-Guard-use-of-mallinfo-with-__GLIBC__.patch \
            file://0006-start-lvm2-monitor.service-after-tmp.mount.patch \
"

SRC_URI:prepend = "file://LVM2.${PV}.tgz \
            file://0001-lvm2-set-default-preferred_names.patch \
            file://0002-lvm2-default-allow-changes-with-duplicate-pvs.patch \
            file://0003-bugfix-lvm2-add-SSD.patch \
            file://0004-bugfix-add-timeout-when-fail-to-wait-udev.patch \
            file://0005-bugfix-fix-the-code-maybe-lead-to-buffer-over-bound-access.patch \
            file://0006-enhancement-modify-default-log-level-to-error-level.patch \
            file://0007-enhancement-add-dfx-log.patch \
            file://0008-enhancement-syslog-more-when-use-libdevmapper-so.patch \
            file://0009-enhancement-log-it-when-disk-slow.patch \
            file://0010-bugfix-lvm2-fix-the-reuse-of-va_list.patch \
            file://0011-13-dm-disk.rules-check-DM_NAME-before-create-symlink.patch \
            file://0012-lvm-code-reduce-cyclomatic-complexity.patch \
            file://0013-udev-repeat.patch \
            file://0014-use-sync-io-read-bcache-by-defaults.patch \
            file://0015-vgchange-acquire-an-exclusive-VG-lock-for-refresh.patch \
            file://0016-dm-event-release-buffer-on-dm_event_get_version.patch \
            file://0017-clean-up-group-struct-in-_stats_create_group-error-path.patch \
" 

# from meta-oe lvm2-2.03.22 recipe
SRC_URI += " \
           file://0001-configure.ac-check-egrep.patch \
           file://0001-include-libgen.h-for-basename.patch \
"

SRC_URI[sha256sum] = "4a63bc8a084a8ae3c7bc5e6530cac264139d218575c64416c8b99e3fe039a05c"

S = "${WORKDIR}/LVM2.${PV}"

# from meta-oe lvm2-2.03.22 recipe

# gold doesn't like multiple dm_bitset_parse_list definitions in libdm/.exported_symbols.DM_1_02_138 and libdm/.exported_symbols.DM_1_02_129
# after it was uncommented in the later in 2.03.12 with https://github.com/lvmteam/lvm2/commit/60eb608d66c2056a78e81f27db3da14139d9faab
LDFLAGS:append = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-gold', " -fuse-ld=bfd", '', d)}"
