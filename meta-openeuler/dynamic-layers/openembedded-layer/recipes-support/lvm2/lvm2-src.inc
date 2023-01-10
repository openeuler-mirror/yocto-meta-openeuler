# use src-openEuler package

# adapt 0005-do-not-build-manual.patch for 2.03.14 version
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

OPENEULER_REPO_NAME = "lvm2"

PV = "2.03.14"

OPENEULER_SRC_URI_REMOVE = "git"

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
           file://0015-_vg_read_raw_area-fix-segfault-caused-by-using-null-.patch \
"

SRC_URI[sha256sum] = "4a63bc8a084a8ae3c7bc5e6530cac264139d218575c64416c8b99e3fe039a05c"

S = "${WORKDIR}/LVM2.${PV}"
