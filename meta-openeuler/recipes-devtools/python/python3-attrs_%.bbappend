PV = "23.2.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=5e55731824cf9205cfabeab9a0600887"

require pypi-src-openeuler.inc

SRC_URI:append = " \
    file://backport-Remove-pytest-deprecated_call.patch \
"
SRC_URI:remove = " \
	file://0001-test_funcs-skip-test_unknown-for-pytest-8.patch \
	file://0001-conftest.py-disable-deadline.patch \
	file://run-ptest \
"
