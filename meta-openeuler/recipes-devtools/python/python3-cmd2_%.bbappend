PV = "2.4.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=209e288518b0668115f58c3929af9ff1"
SRC_URI[md5sum] = "538c02f7e78c7cfbdeafa3acea362c61"
SRC_URI[sha256sum] = "090909ab6c8ecee40813cec759e61dd6e70c8227a1a8e96082f5f2b0d394bc77"
require pypi-src-openeuler.inc

# remove the setup_requires for setuptools-scm(same as python3-pytest):
# The setup_requires argument forces the download of the egg file for setuptools-scm
# during the do_compile phase.  This download is incompatible with the typical fetch
# and mirror structure.  The only usage of scm is the generation of the _version.py
# file and in the release tarball it is already correctly created
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-cmd2/:"
SRC_URI_append += "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"

