# main bbfile: meta-networking/recipes-support/ntp/ntp_4.2.8p15.bb

# version in openEuler
PV = "4.2.8p17"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=3a8ffebbcad335abf2c39fec38671eec"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
           file://ntp-4.2.4_p6-nano.patch \
           file://reproducibility-fixed-path-to-posix-shell.patch \
           file://0001-libntp-Do-not-use-PTHREAD_STACK_MIN-on-glibc.patch \
           file://0001-test-Fix-build-with-new-compiler-defaults-to-fno-com.patch \
           file://0001-sntp-Fix-types-in-check-for-pthread_detach.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://ntp-ssl-libs.patch \
           file://bugfix-fix-bind-port-in-debug-mode.patch \
           file://bugfix-fix-ifindex-length.patch \
           file://fix-MD5-manpage.patch \
           file://backport-add-NULL-pointer-check-when-ntpd-deletes-the-last-interface.patch \
           file://backport-ntpd-abort-if-fail-to-drop-root.patch \
"

