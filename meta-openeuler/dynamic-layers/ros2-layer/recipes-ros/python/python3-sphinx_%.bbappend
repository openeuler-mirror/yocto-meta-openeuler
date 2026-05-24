#main bbfile: yocto-meta-ros/meta-ros-common/recipes-devtools/python/python3-sphinx_1.6.7.bb
#yocto-poky(4.0.x) has a sphinx recipe in meta/recipes-devtools/python/python3-sphinx_4.4.0.bb
PV = "9.0.4"
LICENSE = "BSD-2-Clause & MIT & BSD-3-Clause"

SRC_URI:prepend = "file://sphinx-${PV}.tar.gz "
