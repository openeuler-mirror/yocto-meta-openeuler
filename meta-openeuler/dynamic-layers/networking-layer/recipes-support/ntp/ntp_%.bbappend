# main bbfile: meta-networking/recipes-support/ntp/ntp_4.2.8p15.bb

# version in openEuler
PV = "4.2.8p15"

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
           file://Do-not-use-PTHREAD_STACK_MIN-on-glibc.patch \
           file://bugfix-fix-bind-port-in-debug-mode.patch \
           file://fix-MD5-manpage.patch \
           file://fix-multiple-defination-with-gcc-10.patch \
           file://ntp-ssl-libs.patch \
"

SRC_URI[md5sum] = "e1e6b23d2fc75cced41801dbcd6c2561"
SRC_URI[sha256sum] = "f65840deab68614d5d7ceb2d0bb9304ff70dcdedd09abb79754a87536b849c19"

