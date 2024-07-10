PV = "4.18.2"

# set repo name for xen-tools
OPENEULER_REPO_NAME = "xen"
SRC_URI = " \
    file://RELEASE-${PV}.tar.gz \
    "

# xen-tools also uses the xen source pkg, so specify "xen" instead of "BPN".
S = "${WORKDIR}/xen-RELEASE-${PV}"

# Remove some packages that are less suitable for embedded or are not used by openeuler.
RRECOMMENDS:${PN}-scripts-network:remove = "\
    ifupdown \
    "
RRECOMMENDS:${PN}:remove = " \
    qemu \
    "
