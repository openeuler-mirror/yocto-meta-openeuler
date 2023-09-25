# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/ceres-solver/ceres-solver_2.0.0.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "ceres-solver"

# version in openEuler
PV = "2.0.0"
S = "${WORKDIR}/ceres-solver-${PV}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://ceres-solver-${PV}.tar.gz \
"

# bb need .git to do_configure
do_configure:prepend() {
    mkdir -p ${S}/.git/hooks/
}
