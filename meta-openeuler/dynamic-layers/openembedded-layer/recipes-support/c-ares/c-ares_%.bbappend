# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/c-ares/c-ares_1.16.1.bb

OPENEULER_SRC_URI_REMOVE = "https git"

# version in openEuler
PV = "1.18.1"
S = "${WORKDIR}/c-ares-${PV}"

# files, patches that come from openeuler
SRC_URI = " \
    file://c-ares-${PV}.tar.gz \
    file://0000-Use-RPM-compiler-options.patch \
    file://backport-disable-live-tests.patch \
    file://backport-add-str-len-check-in-config_sortlist-to-avoid-stack-overflow.patch \
    file://backport-CVE-2023-32067.patch \
    file://backport-001-CVE-2023-31130.patch \
    file://backport-002-CVE-2023-31130.patch \
    file://backport-003-CVE-2023-31130.patch \
    file://backport-001-CVE-2023-31147.patch \
    file://backport-002-CVE-2023-31124_CVE-2023-31147.patch \
    file://backport-003-CVE-2023-31147.patch \
    file://backport-004-CVE-2023-31147.patch \
    file://backport-005-CVE-2023-31147.patch \
    file://backport-CVE-2023-31124.patch \
    file://backport-CVE-2024-25629.patch \
"

