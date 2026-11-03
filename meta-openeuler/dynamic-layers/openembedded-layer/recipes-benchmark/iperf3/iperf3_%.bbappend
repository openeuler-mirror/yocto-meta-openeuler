# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/iperf3/iperf3_3.11.bb

PV = "3.22"

LIC_FILES_CHKSUM = "file://LICENSE;md5=f2eb355b6d3b9d63b6b7a861cdc62440"

SRC_URI:prepend = "file://iperf-${PV}.tar.gz \
                   "

# update 0001-configure.ac-check-for-CPP-prog.patch from iperf3_3.16.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

S = "${WORKDIR}/iperf-${PV}"
