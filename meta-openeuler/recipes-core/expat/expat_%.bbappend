# the main bb file: yocto-poky/meta/recipes-core/expat/expat_2.5.0.bb


LIC_FILES_CHKSUM = "file://COPYING;md5=7b3b078238d0901d3b339289117cb7fb"

PV = "2.5.0"

SRC_URI[sha256sum] = "6b902ab103843592be5e99504f846ec109c1abb692e85347587f237a4ffa1033"

# tar from openeuler
SRC_URI = " \
    file://${BP}.tar.gz \
    file://backport-CVE-2024-28757-001.patch \
    file://backport-CVE-2024-28757-002.patch \
    file://backport-CVE-2024-28757-003.patch \
    file://backport-CVE-2024-28757-004.patch \
    file://backport-001-CVE-2023-52426.patch \
    file://backport-002-CVE-2023-52426.patch \
    file://backport-003-CVE-2023-52426.patch \
    file://backport-004-CVE-2023-52426.patch \
    file://backport-001-CVE-2023-52425.patch \
    file://backport-002-CVE-2023-52425.patch \
    file://backport-003-CVE-2023-52425.patch \
    file://backport-004-CVE-2023-52425.patch \
    file://backport-005-CVE-2023-52425.patch \
    file://backport-006-CVE-2023-52425.patch \
    file://backport-007-CVE-2023-52425.patch \
    file://backport-008-CVE-2023-52425.patch \
    file://backport-009-CVE-2023-52425.patch \
    file://backport-001-CVE-2024-45490.patch \
    file://backport-002-CVE-2024-45490.patch \
    file://backport-003-CVE-2024-45490.patch \
    file://backport-CVE-2024-45491.patch \
    file://backport-CVE-2024-45492.patch \
    file://backport-CVE-2024-50602.patch \
    file://backport-CVE-2024-50602-testcase.patch \
    file://backport-001-CVE-2024-8176.patch \
    file://backport-002-CVE-2024-8176.patch \
    file://backport-003-CVE-2024-8176.patch \
    file://backport-004-CVE-2024-8176.patch \
    file://backport-005-CVE-2024-8176.patch \
    file://backport-006-CVE-2024-8176.patch \
    file://backport-007-CVE-2024-8176.patch \
    file://backport-008-CVE-2024-8176.patch \
    file://backport-009-CVE-2024-8176.patch \
    file://backport-010-CVE-2024-8176.patch \
    file://backport-011-CVE-2024-8176.patch \
    file://backport-Stop-updating-m_eventPtr-on-exit-for-reentry.patch \
    file://backport-Make-parser-m_eventPtr-handling-clearer.patch \
    "
