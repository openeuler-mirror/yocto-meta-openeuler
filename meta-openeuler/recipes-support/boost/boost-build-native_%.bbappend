# main bbfile: meta/recipes-support/boost/boost-build-native_4.3.0.bb

OPENEULER_BRANCH = "master"
OPENEULER_REPO_NAME = "boost"

PV = "1.81.0"

SRC_URI:remove = " \
        git://github.com/boostorg/build;protocol=https;branch=master \
"

SRC_URI:prepend = " \
        file://boost_1_81_0.tar.gz \
"

SRC_URI[sha256sum] = "205666dea9f6a7cfed87c7a6dfbeb52a2c1b9de55712c9c1a87735d7181452b6"

S = "${WORKDIR}/boost_1_81_0/tools/build"
