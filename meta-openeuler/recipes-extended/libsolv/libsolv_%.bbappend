PV = "0.7.22"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "968aef452b5493751fa0168cd58745a77c755e202a43fe8d549d791eb16034d5"

SRC_URI = " \
        https://github.com/openSUSE/libsolv/archive/refs/tags/${PV}.tar.gz \
        file://Fix-memory-leak-when-using-testsolv-to-execute-cases.patch \
"

# delete -DENABLE_RPMDB_BDB=ON, not used with new rpm version
PACKAGECONFIG[rpm] = "-DENABLE_RPMMD=ON -DENABLE_RPMDB=ON,,rpm"
