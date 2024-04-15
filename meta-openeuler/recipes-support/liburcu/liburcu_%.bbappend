# main bbfile: yocto-poky/meta/recipes-support/liburcu_0.13.2.bb

# version in openEuler
PV = "0.14.0"

OPENEULER_REPO_NAME = "userspace-rcu"

SRC_URI = "file://userspace-rcu-${PV}.tar.bz2 \
"

SRC_URI[sha256sum] = "ca43bf261d4d392cff20dfae440836603bf009fce24fdc9b2697d837a2239d4f"

S = "${WORKDIR}/${OPENEULER_REPO_NAME}-${PV}"
