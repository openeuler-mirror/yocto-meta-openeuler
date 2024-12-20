PV = "20241017"
WHENCE_CHKSUM  = "f82849fb6325a8a14e21a4feacc5ebb0"

SRC_URI:prepend = " \
 file://${BPN}-${PV}.tar.xz \
"

# not need for oee
SRC_URI:remove = " \
 file://0001-qcom-Add-link-for-QCS6490-GPU-firmware.patch \
"
