# PD.patch will create LICENSE file, but if WORKDIR dir is not a clean
# dir, i.e., LICENSE file is already there because of last build,
# do patch may fail.
SRC_URI:remove = "file://PD.patch"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/PD;md5=b3597d12946881e13cb3b548d1173851"
