# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_8.32.bb

# version in openEuler
PV = "9.0"

# solve lic check failed
LIC_FILES_CHKSUM:remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=b7d80abf5b279320fb0e4b1007ed108b \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        ${GNU_MIRROR}/coreutils/${BP}.tar.xz \
        file://remove-usr-local-lib-from-m4.patch \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://disable-ls-output-quoting.patch \
        file://e8b56ebd536e82b15542a00c888109471936bfda.patch \
        file://0001-ls-restore-8.31-behavior-on-removed-directories.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0001-disable-test-of-rwlock.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://coreutils-getgrouplist.patch \
        file://bugfix-remove-usr-local-lib-from-m4.patch \
        file://bugfix-dummy_help2man.patch \
        file://bugfix-selinux-flask.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch \
        file://backport-chmod-fix-exit-status-when-ignoring-symlinks.patch \
        file://backport-timeout-ensure-foreground-k-exits-with-status-137.patch \
        file://backport-dd-improve-integer-overflow-checking.patch \
        file://backport-dd-do-not-access-uninitialized.patch \
        file://backport-df-fix-memory-leak.patch \
        file://backport-ls-avoid-triggering-automounts.patch \
        file://backport-stat-only-automount-with-cached-never.patch \
        file://backport-config-color-alias-for-ls.patch \
        file://backport-coreutils-i18n.patch \
        file://backport-sort-fix-sort-g-infloop-again.patch \
        file://backport-tests-sort-NaN-infloop-augment-testing-for-recent-fi.patch \
"  

SRC_URI[sha256sum] = "ce30acdf4a41bc5bb30dd955e9eaa75fa216b4e3deb08889ed32433c7b3b97ce"
