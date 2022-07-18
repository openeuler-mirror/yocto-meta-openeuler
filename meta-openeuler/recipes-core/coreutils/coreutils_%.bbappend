# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_8.32.bb

# version in openEuler
PV = "9.0"

# solve lic check failed
LIC_FILES_CHKSUM_remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=b7d80abf5b279320fb0e4b1007ed108b \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/coreutils/${BP}.tar.xz \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://disable-ls-output-quoting.patch \
        file://0001-ls-restore-8.31-behavior-on-removed-directories.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://${BP}.tar.xz;name=tarball \
        file://0001-disable-test-of-rwlock.patch \
        file://backport-timeout-ensure-foreground-k-exits-with-status-137.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch \
        file://backport-chmod-fix-exit-status-when-ignoring-symlinks.patch \
        file://bugfix-dummy_help2man.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://backport-config-color-alias-for-ls.patch \
        file://coreutils-getgrouplist.patch \
"

SRC_URI[tarball.md5sum] = "0d79ae8a6124546e3b94171375e5e5d0"
SRC_URI[tarball.sha256sum] = "ce30acdf4a41bc5bb30dd955e9eaa75fa216b4e3deb08889ed32433c7b3b97ce"
