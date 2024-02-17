# the main bb file: yocto-poky/meta/recipes-core/libcgroup/libcgroup_2.0.2.bb

PV = "2.0.3"

SRC_URI:prepend = " \
            file://${BP}.tar.gz \
            file://config.patch \
"

SRC_URI[sha256sum] = "b29b5704de3d0fadf199fe4e17eeeaecba7f0dd1b85569c96eec37c7672e3026"
