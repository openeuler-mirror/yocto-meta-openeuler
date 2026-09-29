PV = "4.2"

# Refreshed locally against the openEuler linuxptp-4.2 tarball to remove a
# patch-fuzz warning; this copy shadows the one shipped by meta-oe
# (FILESEXTRAPATHS precedence).
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = " \
        file://Use-cross-cpp-in-incdefs.patch \
"

SRC_URI:prepend = " \
        file://${BP}.tgz \
"
