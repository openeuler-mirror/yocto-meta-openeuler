#main bbfile: yocto-meta-ros/meta-ros2/recipes-devtools/graphicsmagick/graphicsmagick_1.3.33.bb
OPENEULER_REPO_NAME = "GraphicsMagick"

LIC_FILES_CHKSUM = "file://Copyright.txt;md5=d46c64029c86acbab3a4deffc237d406"

# version in openEuler
PV = "1.3.41"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://GraphicsMagick-${PV}.tar.xz \
    file://GraphicsMagick-1.3.31-perl_linkage.patch \
"

# remove unused Libs.private to fix: GraphicsMagick.pc failed sanity test (tmpdir)
do_install:append() {
    sed -i '/^Libs\.private/d' ${D}${libdir}/pkgconfig/GraphicsMagick.pc
}

FILES:${PN}:remove = "${datadir}/GraphicsMagick-1.3.33/config ${libdir}/GraphicsMagick-1.3.33/config"
FILES:${PN} += "${datadir}/GraphicsMagick-${PV}/config ${libdir}/GraphicsMagick-${PV}/config"
