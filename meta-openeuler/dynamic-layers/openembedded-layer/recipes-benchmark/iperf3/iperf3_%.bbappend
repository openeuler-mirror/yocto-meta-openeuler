# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/iperf3/iperf3_3.11.bb

PV = "3.13"

S = "${WORKDIR}/iperf-${PV}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=dc6301c8256ceb8f71c9e3c2ae9096b9"
SRC_URI:remove = "git://github.com/esnet/iperf.git;branch=master;protocol=https \
                  file://0002-Remove-pg-from-profile_CFLAGS.patch \
                  file://0001-configure.ac-check-for-CPP-prog.patch \
                  "
SRC_URI:prepend = "file://iperf-${PV}.tar.gz \
                   file://CVE-2023-38403.patch \
                   "
SRC_URI[sha256sum] = "a49d23fe0d3b1482047ad7f3b9e384c69657a63b486c4e3f0ce512a077d94434"

