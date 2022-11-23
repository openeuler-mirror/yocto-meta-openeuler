OPENEULER_REPO_NAME = "grub2"

PV = "2.06"

SRC_URI_remove = " \
    https://alpha.gnu.org/gnu/grub/grub-${REALPV}.tar.xz \
"

SRC_URI_prepend = " \
    file://grub-${PV}.tar.xz \
"

# Notice: openeuler's patches have much confict to patch, drop it.

SRC_URI[sha256sum] = "b79ea44af91b93d17cd3fe80bdae6ed43770678a9a5ae192ccea803ebb657ee1"

S = "${WORKDIR}/grub-${PV}"

CVE_CHECK_WHITELIST = ""
