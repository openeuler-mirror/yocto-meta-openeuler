require suitesparse-openeuler.inc

S = "${WORKDIR}/SuiteSparse-${PV}/SPQR"

EXTRA_OEMAKE += "  LAPACK='-llapack' "
