PV = "2.06"
S = "${WORKDIR}/grub-${PV}"

#these patch can't apply for

SRC_URI_remove = " \
    https://alpha.gnu.org/gnu/grub/grub-${REALPV}.tar.xz \
"

SRC_URI_prepend = " \
    file://grub-${PV}.tar.xz \
"

# Notice: openeuler's patches have much confict to patch, drop it.

OPENEULER_REPO_NAME = "grub2"
SRC_URI[sha256sum] = "b79ea44af91b93d17cd3fe80bdae6ed43770678a9a5ae192ccea803ebb657ee1"

CVE_CHECK_WHITELIST = ""
