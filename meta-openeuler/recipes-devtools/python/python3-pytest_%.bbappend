PV = "6.2.2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=81eb9f71d006c6b268cf4388e3c98f7b"
SRC_URI[md5sum] = "828d15f426ce9740627a9b07e47a318a"
SRC_URI[sha256sum] = "9d1edf9e7d0b84d72ea3dbcdfd22b35fb543a5e8f2a60092dd578936bf63d7f9"
require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "${PYPI_PACKAGE}"

# remove poky conflict patch, we have fit by 0002-patch
SRC_URI_remove += "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch "
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-pytest/:"
SRC_URI_append += "file://0002-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"

