PV = "2.4.3"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fad7740aa21780c8b9a214f5b320b4ad"
require pypi-src-openeuler.inc

# remove the setup_requires for setuptools-scm(same as python3-pytest):
# The setup_requires argument forces the download of the egg file for setuptools-scm
# during the do_compile phase.  This download is incompatible with the typical fetch
# and mirror structure.  The only usage of scm is the generation of the _version.py
# file and in the release tarball it is already correctly created
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-cmd2/:"
SRC_URI:append = "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"

