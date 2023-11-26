# main bbfile: yocto-poky/meta/recipes-kernel/blktrace_git.bb

OPENEULER_SRC_URI_REMOVE = "git"

PV = "1.3.0"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://0001-blktrace-remove-python2-dedpendency.patch \
        file://0002-blktrace-Makefile-add-fstack-protector-strong-flag.patch \
        file://0003-blktrace-fix-exit-directly-when-nthreads-running.patch \
        "

S = "${WORKDIR}/${BP}"
