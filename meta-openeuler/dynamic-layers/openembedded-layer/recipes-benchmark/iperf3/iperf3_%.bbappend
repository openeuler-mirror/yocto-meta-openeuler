# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/iperf3/iperf3_3.11.bb

PV = "3.16"

LIC_FILES_CHKSUM = "file://LICENSE;md5=dc6301c8256ceb8f71c9e3c2ae9096b9"

SRC_URI:prepend = "file://iperf-${PV}.tar.gz \
                   "

# update 0001-configure.ac-check-for-CPP-prog.patch from iperf3_3.16.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

S = "${WORKDIR}/iperf-${PV}"
