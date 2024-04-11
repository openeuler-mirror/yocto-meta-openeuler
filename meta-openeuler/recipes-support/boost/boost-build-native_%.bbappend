# main bbfile: meta/recipes-support/boost/boost-build-native_4.3.0.bb

OPENEULER_REPO_NAME = "boost"

PV = "1.83.0"

BOOST_VER = "${@"_".join(d.getVar("PV").split("."))}"
BOOST_P = "boost_${BOOST_VER}"

SRC_URI:prepend = " \
        file://${BOOST_P}.tar.gz \
"

S = "${WORKDIR}/${BOOST_P}/tools/build"
