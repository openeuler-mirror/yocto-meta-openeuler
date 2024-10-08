# main bbfile: yocto-poky/meta/recipes-kernel/blktrace_git.bb

PV = "1.3.0"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://0001-blktrace-remove-python2-dedpendency.patch \
        file://0002-blktrace-Makefile-add-fstack-protector-strong-flag.patch \
        file://0003-blktrace-fix-exit-directly-when-nthreads-running.patch \
        file://0004-blkparse-skip-check_cpu_map-with-pipe-input.patch \
        file://0005-blkparse-fix-incorrectly-sized-memset-in-check_cpu_m.patch \
        file://0006-fix-hang-when-BLKTRACESETUP-fails-and-o-is-used.patch \
        "

S = "${WORKDIR}/${BP}"
