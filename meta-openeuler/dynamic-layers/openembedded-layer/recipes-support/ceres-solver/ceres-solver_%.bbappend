# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/ceres-solver/ceres-solver_2.0.0.bb
# version in openEuler
PV = "2.0.0"
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

# bb need .git to do_configure
do_configure:prepend() {
    mkdir -p ${S}/.git/hooks/
}

PACKAGECONFIG[suitesparse] = "-DSUITESPARSE=ON,-DSUITESPARSE=OFF,suitesparse"
PACKAGECONFIG[cxsparse] = "-DCXSPARSE=ON,-DCXSPARSE=OFF,suitesparse"
