# main bb file: yocto-meta-openembedded/meta-oe/recipes-benchmark/iozone3/iozone3_492.bb

# adapt parallelism.patch for 490 version
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "490"

SRC_URI:remove = "http://www.iozone.org/src/current/${BPN}_${PV}.tar \
                  "
SRC_URI:prepend = "file://${BPN}_${PV}.tar \
                   "
SRC_URI[sha256sum] = "5eadb4235ae2a956911204c50ebf2d8d8d59ddcd4a2841a1baf42f3145ad4fed"

