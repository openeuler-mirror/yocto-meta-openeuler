# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libtinyxml2/libtinyxml2_8.0.0.bb

# openeuler version
PV = "6.0.0"

OPENEULER_REPO_NAME = "tinyxml2"

LIC_FILES_CHKSUM = "file://readme.md;md5=7592e8f93f0317236424a2f6f34121a7"

S = "${WORKDIR}/tinyxml2-8c8293ba8969a46947606a93ff0cb5a083aab47a"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = "git://github.com/leethomason/tinyxml2.git;branch=master;protocol=https "

SRC_URI += "file://tinyxml2-${PV}-8c8293b.tar.gz "

# make libs compatible with lib64
do_configure_prepend_class-target() { 
    if [ -f ${S}/CMakeLists.txt ] && [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/CMakeLists.txt | grep "DESTINATION lib\${LIB_SUFFIX}" || sed -i 's:DESTINATION lib:DESTINATION lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
    fi
}
