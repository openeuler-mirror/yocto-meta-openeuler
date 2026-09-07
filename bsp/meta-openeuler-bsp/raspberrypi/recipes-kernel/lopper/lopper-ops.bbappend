# Use the operation files from current layer
FILESEXTRAPATHS:prepend := "${THISDIR}/:"

# The central lopper-ops.bbappend in meta-openeuler does "include
# ${MACHINE}.inc", which searches its own directory first and then
# BBPATH (layer roots only).  raspberrypi4-64.inc lives here in the
# BSP layer, so that include can never find it and silently skips.
# Require it explicitly (require resolves relative to this file's
# directory first) so the uart5 extraction lop is added to SRC_URI.
require raspberrypi4-64.inc
