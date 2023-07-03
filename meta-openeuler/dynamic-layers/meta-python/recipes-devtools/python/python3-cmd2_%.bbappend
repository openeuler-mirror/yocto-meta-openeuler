PV = "2.4.2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=209e288518b0668115f58c3929af9ff1"
SRC_URI[md5sum] = "9c54a6eb188f6673e32be3e22941ba39"
SRC_URI[sha256sum] = "f328ed33d70a32267f141c5c310f61ed7fcce049094223db2ea2247d62e72c10"
require pypi-src-openeuler.inc

# remove the setup_requires for setuptools-scm(same as python3-pytest):
# The setup_requires argument forces the download of the egg file for setuptools-scm
# during the do_compile phase.  This download is incompatible with the typical fetch
# and mirror structure.  The only usage of scm is the generation of the _version.py
# file and in the release tarball it is already correctly created
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-cmd2/:"
SRC_URI:append = "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"

