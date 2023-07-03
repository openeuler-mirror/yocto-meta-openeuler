# use src-openEuler package

# adapt 0005-do-not-build-manual.patch for 2.03.14 version
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

OPENEULER_REPO_NAME = "lvm2"

DEPENDS += "libaio"

PV = "2.03.18"

OPENEULER_SRC_URI_REMOVE = "git"

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
" 

SRC_URI[sha256sum] = "4a63bc8a084a8ae3c7bc5e6530cac264139d218575c64416c8b99e3fe039a05c"

S = "${WORKDIR}/LVM2.${PV}"
