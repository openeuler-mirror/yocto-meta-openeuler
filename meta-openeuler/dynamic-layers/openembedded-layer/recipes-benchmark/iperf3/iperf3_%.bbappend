# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/iperf3/iperf3_3.11.bb

PV = "3.17.1"

LIC_FILES_CHKSUM = "file://LICENSE;md5=f9873a72f714e240530e759e103ac7b2"

SRC_URI:prepend = "file://iperf-${PV}.tar.gz \
                   "

# update 0001-configure.ac-check-for-CPP-prog.patch from iperf3_3.16.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

S = "${WORKDIR}/iperf-${PV}"
