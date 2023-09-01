PV = "1.6.2"
require pypi-src-openeuler.inc

# rolls back the conflicting patches
SRC_URI:remove = " \
        file://run-ptest \
"

LIC_FILES_CHKSUM = "file://LICENSE.rst;md5=42cd19c88fc13d1307a4efd64ee90e4e"
