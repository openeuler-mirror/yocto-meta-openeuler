# main bb file: yocto-meta-openeuler/meta-openeuler/recipes-core/libcgroup_2.0.2.bb

PV = "2.0.3"

SRC_URI = "\
    file://${BPN}-${PV}.tar.gz \
    file://config.patch \
"

SRC_URI[sha256sum] = "b29b5704de3d0fadf199fe4e17eeeaecba7f0dd1b85569c96eec37c7672e3026"

