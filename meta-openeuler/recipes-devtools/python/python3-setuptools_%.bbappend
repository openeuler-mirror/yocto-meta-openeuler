PV = "68.0.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=141643e11c48898150daa83802dbc65f"

FILESEXTRAPATHS:prepend := "${THISDIR}/python3-setuptools/:"

# the base recipe applies 0001-conditionally-do-not-fetch-code-by-easy_install.patch
# to class-native only. its context was written for setuptools <= 67 (rmtree(tmpdir)),
# while openEuler 68.0.0 uses _rmtree(tmpdir), so the poky copy applies with fuzz.
# the refreshed copy with the same name in python3-setuptools/ shadows the poky one
# via FILESPATH priority: SRC_URI still has a single entry, so only this copy is
# applied and do_patch reports no patch-fuzz.
require pypi-src-openeuler.inc

SRC_URI:remove = " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-_distutils-sysconfig-append-STAGING_LIBDIR-python-sy.patch \
        file://0001-Limit-the-amount-of-whitespace-to-search-backtrack.-.patch \
"

SRC_URI[sha256sum] = "baf1fdb41c6da4cd2eae722e135500da913332ab3f2f5c7d33af9b492acb5235"

# the openeuler patch
SRC_URI:append = " file://bugfix-eliminate-random-order-in-metadata.patch \
        file://backport-CVE-2024-6345.patch \
"
