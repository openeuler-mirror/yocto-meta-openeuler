SUMMARY = "Orocos toolchain"

LICENSE = "gplv2"
LIC_FILES_CHKSUM = "file://README.md;md5=cd17313f58b21a50d8f16647f5be4bcd"

DEPENDS += " \
  boost \
  ruby-native \
  xerces-c \
  libxml2 \
  "

SYSROOT_DIRS += "/opt/orocos \
  "

OPENEULER_LOCAL_NAME = "oee_archive"
SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
"
S = "${WORKDIR}/orocos_toolchain"
do_package_qa[noexec] = "1"
inherit cmake
EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/orocos \
  -DBUILD_OROGEN=TRUE \
  -DENABLE_CORBA=OFF \
  "

BOOST_ROOT = "${STAGING_DIR_HOST}/usr"

INSTALL_PREFIX = "${STAGING_DIR_HOST}/opt/orocos"
INSTALL_PREFIX_NATIVE = "/opt/orocos"

do_compile:prepend(){
  export BOOST_ROOT=${BOOST_ROOT}
  
}

FILES:${PN}:append = " /opt/orocos/include /opt/orocos/lib /opt/orocos/bin /opt/orocos/share /opt/orocos/etc /opt/orocos/setup.sh /opt/orocos/env.sh "