# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/glog/glog_0.4.0.bb

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "glog"
OPENEULER_BRANCH = "master"

# version in openEuler
PV = "0.3.5"
S = "${WORKDIR}/glog-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        file://libexecinfo.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://glog-${PV}.tar.gz \
"

SRC_URI[md5sum] = "5df6d78b81e51b90ac0ecd7ed932b0d4"
SRC_URI[sha256sum] = "7580e408a2c0b5a89ca214739978ce6ff480b5e7d8d7698a2aa92fadc484d1e0"

# make libs compatible with lib64
do_configure_prepend_class-target() { 
    if [ -f ${S}/CMakeLists.txt ] && [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/CMakeLists.txt | grep "DESTINATION lib\${LIB_SUFFIX}" || sed -i 's:DESTINATION lib:DESTINATION lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
    fi
}
