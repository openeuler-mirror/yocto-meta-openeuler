# main bb src: openembedded-core/recipes-support/boost/boost-1.80.0*

PV = "1.80.0"

LIC_FILES_CHKSUM = "file://LICENSE_1_0.txt;md5=e4224ccaecb14d942c71d31bef20d78c"  

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_remove = " \
        https://boostorg.jfrog.io/artifactory/main/release/${PV}/source/${BOOST_P}.tar.bz2 \
"

SRC_URI_prepend = " \
        file://boost_1_80_0.tar.gz \
        file://boost-1.78-python-Update-call_method-hpp.patch \
"

SRC_URI[md5sum] = "077f074743ea7b0cb49c6ed43953ae95"
SRC_URI[sha256sum] = "4b2136f98bdd1f5857f1c3dea9ac2018effe65286cf251534b6ae20cc45e1847"

S = "${WORKDIR}/boost_1_80_0"

OPENEULER_BRANCH = "master"
OPENEULER_REPO_NAME = "boost"
