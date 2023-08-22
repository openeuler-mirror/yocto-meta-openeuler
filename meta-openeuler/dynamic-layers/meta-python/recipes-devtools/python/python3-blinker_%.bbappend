PV = "1.5"
require pypi-src-openeuler.inc

# rolls back the conflicting patches
SRC_URI:remove = " \
        file://0001-use-pytest-instead-of-deprecated-nose.patch \
        file://run-ptest \
"

SRC_URI[md5sum] = "e1c3eec8e52210f69ef59d299c6cca07"
SRC_URI[sha256sum] = "923e5e2f69c155f2cc42dafbbd70e16e3fde24d2d4aa2ab72fbe386238892462"
LIC_FILES_CHKSUM = "file://LICENSE.rst;md5=42cd19c88fc13d1307a4efd64ee90e4e"
