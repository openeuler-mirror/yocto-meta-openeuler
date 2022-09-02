# run-postinsts does not require code download, to avoid the conflict of run-postinsts folder
# (set by DL_DIR ?= "${OPENEULER_SP_DIR}/${BPN}" )
# and run-postinsts script file (with run-postinsts_1.0.bb ), here set DL_DIR back to ${TOPDIR}/downloads
DL_DIR = "${TOPDIR}/downloads"
