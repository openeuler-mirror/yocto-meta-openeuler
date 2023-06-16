require suitesparse-openeuler.inc

S = "${WORKDIR}/SuiteSparse-${PV}/CHOLMOD"

EXTRA_OEMAKE += "  LAPACK='-llapack' "
