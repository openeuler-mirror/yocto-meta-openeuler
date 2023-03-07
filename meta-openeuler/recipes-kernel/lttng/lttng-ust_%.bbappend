# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.12.1.bb

FILESEXTRAPATHS_append := "${THISDIR}/${BPN}/:"

# version in openEuler
PV = "2.10.1"

# used openEuler-22.09 because arm build will be error
OPENEULER_BRANCH = "openEuler-22.09"

# apply openEuler patches
SRC_URI_prepend = "file://Fix-namespace-our-gettid-wrapper.patch \
           file://lttng-gen-tp-shebang.patch \
           file://fix-build-with-fno-common.patch \
           file://0001-Adapt-lttng-ust-to-use-multiflavor-symbols-form-liburcu-0.11.patch \
"

# apply openembedded-core patch;branch=warrior
SRC_URI_append = "file://lttng-ust-doc-examples-disable.patch \
"

# this version does not have this option
EXTRA_OECONF_remove = "--disable-numa"

PACKAGECONFIG[examples] = ",,,"

SRC_URI[md5sum] = "4863cc2f9f0a070b42438bb646bbba06"
SRC_URI[sha256sum] = "07cc3c0b71e7b77f1913d5b7f340a78a9af414440e4662712aef2d635b88ee9d"
