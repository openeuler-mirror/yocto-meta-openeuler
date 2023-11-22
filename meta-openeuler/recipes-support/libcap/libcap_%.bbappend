# main bbfile: yocto-poky/meta/recipes-support/libcap/libcap_2.48.bb

OPENEULER_SRC_URI_REMOVE = "git https http"

PV = "2.61"

LIC_FILES_CHKSUM = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
    ${KERNELORG_MIRROR}/linux/libs/security/linux-privs/${BPN}2/${BPN}-${PV}.tar.xz \
    file://0001-ensure-the-XATTR_NAME_CAPS-is-defined-when-it-is-use.patch \
    file://0001-tests-do-not-statically-link-a-test.patch \
    file://0002-tests-do-not-run-target-executables.patch \
"
# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://${BPN}-${PV}.tar.gz \
    file://libcap-buildflags.patch \
    file://Fix-syntax-error-in-DEBUG-protected-setcap.c-code.patch \
    file://backport-psx-free-allocated-memory-at-exit.patch \
    file://backport-Avoid-a-deadlock-in-forked-psx-thread-exit.patch \
    file://backport-getpcaps-catch-PID-parsing-errors.patch \
    file://backport-Correct-the-check-of-pthread_create-s-return-value.patch \
    file://backport-Large-strings-can-confuse-libcap-s-internal-strdup-c.patch \
    file://backport-There-was-a-small-memory-leak-in-pam_cap.so-when-lib.patch \
    file://backport-libcap-Ensure-the-XATTR_NAME_CAPS-is-define.patch \
"

# BUILD_GPERF is now reserved, please use USE_GPERF=yes or no instead.
EXTRA_OEMAKE_remove = "BUILD_GPERF=yes \
"
EXTRA_OEMAKE_append = "USE_GPERF=yes \
"

# use cross compile objcopy
# set lib dir, not use ldd to find, maybe fail
EXTRA_OEMAKE_class-target = " \
    OBJCOPY="${OBJCOPY}" \ 
    lib="${base_libdir}" \
"
