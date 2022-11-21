# main bb src: openembedded-core/recipes-support/boost/boost-1.80.0*

PV = "1.80.0"

SRC_URI_remove = " \
        git://github.com/boostorg/build;protocol=https;branch=master \
"

SRC_URI_prepend = " \
        file://boost_1_80_0.tar.gz \
"

S = "${WORKDIR}/boost_1_80_0/tools/build"

OPENEULER_BRANCH = "master"
OPENEULER_REPO_NAME = "boost"
