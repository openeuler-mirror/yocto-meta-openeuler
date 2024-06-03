LICENSE = "MulanPSLv2"
LIC_FILES_CHKSUM = "file://README.md;md5=4bf7fb6fb9c07b28de67367a205551c8"

DEPENDS += " \
  boost \
  glog \
  libunwind \
  googletest \
  libeigen \
  libxml2 \
  lua \
  protobuf \
  protobuf-c \
  grpc-native \
  ethercat-igh \
  orocos-toolchain \
  swig \
  ruby-native \
  orocos-kdl \
  yaml-cpp \
  nlopt \
  "

OPENEULER_REPO_NAME = "robot-brain"
SRC_URI = "file://robot-brain \
  "
S = "${WORKDIR}/robot-brain"
do_package_qa[noexec] = "1"
inherit cmake


do_configure() {
  export OROCOS_INSTALL_PREFIX=${STAGING_DIR_HOST}/opt/orocos
  export PATH=${PATH}:${OROCOS_INSTALL_PREFIX}/bin
  export PKG_CONFIG_PATH=${OROCOS_INSTALL_PREFIX}/lib/pkgconfig
  export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:${OROCOS_INSTALL_PREFIX}:${OROCOS_INSTALL_PREFIX}/include/orocos:${STAGING_DIR_HOST}/usr/lib64/cmake:${STAGING_DIR_HOST}/usr/share/eigen3/cmake:${STAGING_DIR_HOST}/usr/
  export RTT_COMPONENT_PATH=${OROCOS_INSTALL_PREFIX}/lib/orocos

  mkdir -p ${B}
  cd ${B}
  cmake ${S} 
}

do_compile() {
    cd ${B}
    make -j$(nproc)

}

do_install() {
    cd ${B}
    make install DESTDIR=${D}
}

FILES:${PN}:append = " /usr/local/include /usr/local/lib /usr/local/share  /usr/local/bin"