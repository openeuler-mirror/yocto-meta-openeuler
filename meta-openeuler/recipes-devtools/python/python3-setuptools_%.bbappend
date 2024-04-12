PV = "68.0.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=141643e11c48898150daa83802dbc65f"

FILESEXTRAPATHS:prepend := "${THISDIR}/python3-setuptools/:"

require pypi-src-openeuler.inc

SRC_URI:remove = " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-_distutils-sysconfig-append-STAGING_LIBDIR-python-sy.patch \
        file://0001-Limit-the-amount-of-whitespace-to-search-backtrack.-.patch \
"

SRC_URI[sha256sum] = "baf1fdb41c6da4cd2eae722e135500da913332ab3f2f5c7d33af9b492acb5235"

# the upstream patch
# SRC_URI:append:class-native = " file://0001-conditionally-do-not-fetch-code-by-easy_install.patch"
SRC_URI:append = " file://0001-_distutils-sysconfig.py-make-it-possible-to-substite.patch"

# the openeuler patch
SRC_URI:append = " file://bugfix-eliminate-random-order-in-metadata.patch"
