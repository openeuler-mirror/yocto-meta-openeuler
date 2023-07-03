REALPV = "2.06"
PV = "2.06"

# Notice: openeuler's patches have many conflicts to patch, drop them.

OPENEULER_REPO_NAME = "grub2"

SRC_URI:remove = "${GNU_MIRROR}/grub/grub-${PV}.tar.gz \
"

SRC_URI:prepend = "file://grub-${PV}.tar.xz \
"

SRC_URI[sha256sum] = "b79ea44af91b93d17cd3fe80bdae6ed43770678a9a5ae192ccea803ebb657ee1"

CVE_CHECK_IGNORE = ""
