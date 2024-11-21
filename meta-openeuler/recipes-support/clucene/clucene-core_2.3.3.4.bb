SUMMARY = "CLucene is a indexing and searching API"
HOMEPAGE = "http://www.sourceforge.net/projects/clucene"
LICENSE = "LGPL-2.0-or-later & Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://APACHE.license;md5=86d3f3a95c324c9479bd8986968f4327 \
    file://LGPL.license;md5=464215a90afcdfbae965d89feb928c7e \
    file://COPYING;md5=b2e941b2872bb8566f505130d6d61ba4 \
"
SRC_URI = " \
    ${SOURCEFORGE_MIRROR}/project/clucene/${BPN}-unstable/2.3/${BPN}-${PV}.tar.gz \
    file://0001-cmake-remplace-CHECK_CXX_SOURCE_RUNS-by-CHECK_CXX_SO.patch \
    file://0002-exclude-external-sources-from-build.patch \
    file://0003-align-pkg-config.patch \
    file://0004-fix-location-s-for-our-cmake-config.patch \
    file://0005-install-contribs-lib.patch \
    file://0006-Fix-build-with-glibc-2.36.patch \
"
SRC_URI[md5sum] = "48d647fbd8ef8889e5a7f422c1bfda94"
SRC_URI[sha256sum] = "ddfdc433dd8ad31b5c5819cc4404a8d2127472a3b720d3e744e8c51d79732eab"

inherit cmake

DEPENDS = "boost zlib"

EXTRA_OECMAKE = " \
    -DLIB_SUFFIX=${@d.getVar('baselib').replace('lib', '')} \
    -DENABLE_COMPILE_TESTS=OFF \
    -DBUILD_CONTRIBS_LIB:BOOL=ON"

BBCLASSEXTEND = "native"

