PV = "0.7.22"

S = "${WORKDIR}/${BP}"

OPENEULER_BRANCH = "master"
SRC_URI[sha256sum] = "968aef452b5493751fa0168cd58745a77c755e202a43fe8d549d791eb16034d5"

SRC_URI = " \
        file://${PV}.tar.gz \
        file://Fix-memory-leak-when-using-testsolv-to-execute-cases.patch \
        file://backport-Treat-condition-both-as-positive-and-negative-literal-in-pool_add_pos_literals_complex_dep.patch \
        file://backport-Add-testcase-for-last-commit.patch \
        file://backport-choice-rules-also-do-solver_choicerulecheck-for-package-downgrades.patch \
"

# delete -DENABLE_RPMDB_BDB=ON, not used with new rpm version
PACKAGECONFIG[rpm] = "-DENABLE_RPMMD=ON -DENABLE_RPMDB=ON,,rpm"
