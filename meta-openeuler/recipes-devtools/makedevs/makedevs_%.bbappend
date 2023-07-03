# COPYING.patch will create LICENSE file, but if WORKDIR dir is not a clean
# dir, i.e., COPYING file is already there because of last build,
# do patch may fail.
SRC_URI:remove = "file://COPYING.patch"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"
