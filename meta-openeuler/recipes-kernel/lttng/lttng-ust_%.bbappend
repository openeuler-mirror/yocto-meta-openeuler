# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.12.1.bb

FILESEXTRAPATHS_append := "${THISDIR}/${BPN}/:"
OPENEULER_SRC_URI_REMOVE = "http https git"

# version in openEuler
PV = "2.10.1"

# update LICENSE checksums
LIC_FILES_CHKSUM = "file://COPYING;md5=c963eb366b781252b0bf0fdf1624d9e9"

SRC_URI_remove = " \
           file://0001-python-lttngust-Makefile.am-Add-install-lib-to-setup.patch \
"

# 2.10.1 not support --disable-numa and --disable-examples
EXTRA_OECONF = ""
PACKAGECONFIG[examples] = ""

# apply new poky patches
SRC_URI_append = " \
            file://lttng-ust-${PV}.tar.bz2 \
            file://lttng-ust-doc-examples-disable.patch \
            file://Fix-namespace-our-gettid-wrapper.patch \
            file://lttng-gen-tp-shebang.patch \
            file://fix-build-with-fno-common.patch \
            file://0001-Adapt-lttng-ust-to-use-multiflavor-symbols-form-liburcu-0.11.patch \
            "

SRC_URI[md5sum] = "4863cc2f9f0a070b42438bb646bbba06"
SRC_URI[sha256sum] = "07cc3c0b71e7b77f1913d5b7f340a78a9af414440e4662712aef2d635b88ee9d"
