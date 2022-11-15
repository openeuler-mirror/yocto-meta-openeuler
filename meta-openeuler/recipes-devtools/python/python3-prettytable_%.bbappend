PV = "2.4.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=c9a6829fcd174d9535b46211917c7671"
SRC_URI[md5sum] = "c4784a3ea8bd6b326932d112458e051a"
SRC_URI[sha256sum] = "18e56447f636b447096977d468849c1e2d3cfa0af8e7b5acfcf83a64790c0aca"

SRC_URI_remove += " \
        https://pypi.python.org/packages/source/P/PrettyTable/${SRCNAME}-${PV}.zip \
        "

OPENEULER_REPO_NAME = "python-prettytable"
OPENEULER_BRANCH = "master"
SRC_URI_prepend += "file://prettytable-${PV}.tar.gz "

DEPENDS += "python3-pip-native"
