# main bbfile: yocto-poky/meta/recipes-core/coreutils/coreutils_9.0.bb
# version in openEuler
PV = "9.5"

# solve lic check failed
LIC_FILES_CHKSUM:remove = " \
        file://src/ls.c;beginline=1;endline=15;md5=3b8fbaee597c8a9bb88d30840d53048c \
"
LIC_FILES_CHKSUM += " \
        file://src/ls.c;beginline=1;endline=15;md5=9ac94aaed7fd46fd8df7147a9e3410cb \
"

# files, patches can't be applied in openeuler or conflict with openeuler
# remove-usr-local-lib-from-m4.patch same as bugfix-remove-usr-local-lib-from-m4.patch
SRC_URI:remove = " \
        file://remove-usr-local-lib-from-m4.patch \
        file://fix-selinux-flask.patch \
        file://0001-uname-report-processor-and-hardware-correctly.patch \
        file://e8b56ebd536e82b15542a00c888109471936bfda.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0001-disable-test-of-rwlock.patch \
        file://coreutils-8.2-uname-processortype.patch \
        file://bugfix-remove-usr-local-lib-from-m4.patch \
        file://bugfix-dummy_help2man.patch \
        file://skip-the-tests-that-require-selinux-if-selinux-is-di.patch  \
        file://backport-config-color-alias-for-ls.patch \
        file://backport-coreutils-df-direct.patch \
        file://backport-coreutils-i18n.patch \
        file://test-skip-overlay-filesystem-because-of-no-inotify_add_watch.patch \
"

SRC_URI[sha256sum] = "ea613a4cf44612326e917201bbbcdfbd301de21ffc3b59b6e5c07e040b275e52"

ASSUME_PROVIDE_PKGS = "coreutils"
