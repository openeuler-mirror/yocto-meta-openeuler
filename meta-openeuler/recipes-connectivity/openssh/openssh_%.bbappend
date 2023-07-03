# main bb ref:
# http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-connectivity/openssh/openssh_9.1p1.bb?id=c80a3a7a4a9dc40cbb675777a1ba1481532ecb05

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "9.1p1"

# notice files in openssh is all from higher version of oe
# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-connectivity/openssh/openssh?id=c80a3a7a4a9dc40cbb675777a1ba1481532ecb05
FILESEXTRAPATHS:prepend := "${THISDIR}/openeuler-config/:"

# conflict: other openeuler patches can't apply
SRC_URI += " \
        file://openssh-9.1p1.tar.gz \
        file://backport-upstream-CVE-2023-25136-fix-double-free-caused.patch \
        "
