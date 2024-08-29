# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/glog/glog_0.5.0.bb
# version in openEuler
PV = "0.7.1"
S = "${WORKDIR}/${BP}"

SRC_URI = " \
    file://${BP}.tar.gz \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=583a6ead531ca3cd5a2ea593a2888800"

# From meta-openembedded, glog_0.6.0.bb
PACKAGECONFIG[64bit-atomics] = ",-DCMAKE_CXX_STANDARD_LIBRARIES='-latomic',,"
FILES:${PN}-dev += "${datadir}/${BPN}/cmake"

# make libs compatible with lib64
do_configure:prepend:class-target() {
    if [ -f ${S}/CMakeLists.txt ] && [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/CMakeLists.txt | grep "DESTINATION lib\${LIB_SUFFIX}" || sed -i 's:DESTINATION lib:DESTINATION lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
    fi
}
