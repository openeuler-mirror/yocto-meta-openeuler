PV = "7.0.1"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bd27e41b6550fe0fc45356d1d81ee37c"
SRC_URI[md5sum] = "995d64fe44bbe717d03bd703d5c48ec6"
SRC_URI[sha256sum] = "e30905a0c131d3d94b89624a1cc5afec3e0ba2fbdb151867d8e0ebd49850f171"
require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "${PYPI_PACKAGE}"

# remove poky conflict patch, we have fit by 0002-patch
SRC_URI:remove = "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch "
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-pytest/:"
SRC_URI:append = "file://0002-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"

