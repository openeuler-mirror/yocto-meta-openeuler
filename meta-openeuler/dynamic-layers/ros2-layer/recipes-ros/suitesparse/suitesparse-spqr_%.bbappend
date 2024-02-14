require suitesparse-openeuler.inc


S = "${WORKDIR}/SuiteSparse-${SUITESPARSE_PV}/SPQR"

EXTRA_OEMAKE += "  LAPACK='-llapack' "
