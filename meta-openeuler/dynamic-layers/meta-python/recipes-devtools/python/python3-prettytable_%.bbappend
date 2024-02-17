PV = "2.4.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=c9a6829fcd174d9535b46211917c7671"
SRC_URI[md5sum] = "c4784a3ea8bd6b326932d112458e051a"
SRC_URI[sha256sum] = "18e56447f636b447096977d468849c1e2d3cfa0af8e7b5acfcf83a64790c0aca"

OPENEULER_REPO_NAME = "python-prettytable"

SRC_URI:prepend = "file://prettytable-${PV}.tar.gz "

# remove the setup_requires for setuptools-scm(same as python3-pytest):
# The setup_requires argument forces the download of the egg file for setuptools-scm
# during the do_compile phase.  This download is incompatible with the typical fetch
# and mirror structure.  The only usage of scm is the generation of the _version.py
# file and in the release tarball it is already correctly created
FILESEXTRAPATHS:prepend := "${THISDIR}/python3-prettytable/:"
SRC_URI:append = "file://0001-setup.py-remove-the-setup_requires-for-setuptools-scm.patch"
