# main bbfile: yocto-poky/meta/recipes-kernel/kmod/kmod_git.bb

# kmod version in openEuler
PV = "30"

# Use the source packages from openEuler
SRC_URI:remove = " \
        file://0001-depmod-Add-support-for-excluding-a-directory.patch \
        "
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://backport-check-strtol-strtoul-strtoull-results.patch \
        file://backport-libkmod-clear-file-memory-if-map-fails.patch \
        file://backport-libkmod-do-not-crash-on-unknown-signature-algorithm.patch \
        file://backport-libkmod-error-out-on-unknown-hash-algorithm.patch \
        file://backport-libkmod-fix-possible-out-of-bounds-memory-access.patch \
        file://backport-libkmod-Fix-UB-for-non-existent-keys.patch \
        file://backport-shared-avoid-passing-NULL-0-array-to-bsearch.patch \
        file://backport-testsuite-repair-read-of-uninitialized-memory.patch \
        file://backport-tools-modprobe-Fix-odd-remove-holders-behavior.patch \
        file://backport-util-fix-endless-loop-in-get_backoff_delta_msec.patch \
        "

SRC_URI[md5sum] = "85202f0740a75eb52f2163c776f9b564"
SRC_URI[sha256sum] = "f897dd72698dc6ac1ef03255cd0a5734ad932318e4adbaebc7338ef2f5202f9f"

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "kmod kmod-libs"
