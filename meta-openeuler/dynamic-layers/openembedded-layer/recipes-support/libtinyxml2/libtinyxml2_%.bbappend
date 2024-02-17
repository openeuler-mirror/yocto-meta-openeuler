# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libtinyxml2/libtinyxml2_9.0.0.bb

# openeuler version
PV = "9.0.0"

OPENEULER_REPO_NAME = "tinyxml2"

# the dir name after unpacking the tar file
S = "${WORKDIR}/tinyxml2-${PV}"

SRC_URI += "file://tinyxml2-${PV}.tar.gz "

# make libs compatible with lib64
do_configure:prepend:class-target() { 
    if [ -f ${S}/CMakeLists.txt ] && [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/CMakeLists.txt | grep "DESTINATION lib\${LIB_SUFFIX}" || sed -i 's:DESTINATION lib:DESTINATION lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
    fi
}
