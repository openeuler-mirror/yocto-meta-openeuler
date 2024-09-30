SUMMARY = "openeuler embedded benchmark packages"
DESCRIPTION = "packages for openeuler embedded benchmark"

inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

# benchmarks packages are used for benchmark and tests, are not for final deployment,
# lmbench, src-openeuler use lmbench-3.0-a4, but poky use lmbench-3.0-a9, difficult to
#          use openeuler version, so use the upstream version
# NOTE:currently, most of the benchmark packages are not available in openeuler, so use
# openembedded's recipes-benchmarks, but redefine according to the openeuler embedded's need
RDEPENDS:${PN} = " \
    lmbench \
    iperf3 \
    sysbench \
    iozone3 \
    dhrystone \
    fio \
"
