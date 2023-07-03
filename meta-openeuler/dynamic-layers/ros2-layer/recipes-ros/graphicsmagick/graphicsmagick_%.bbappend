#main bbfile: yocto-meta-ros/meta-ros2/recipes-devtools/graphicsmagick/graphicsmagick_1.3.33.bb
OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "GraphicsMagick"

LIC_FILES_CHKSUM = "file://Copyright.txt;md5=d46c64029c86acbab3a4deffc237d406"

# version in openEuler
PV = "1.3.38"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        ${SOURCEFORGE_MIRROR}/${BPN}/GraphicsMagick-${PV}.tar.bz2 \
        "

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://GraphicsMagick-${PV}.tar.xz \
    file://GraphicsMagick-1.3.16-multilib.patch \
    file://GraphicsMagick-1.3.31-perl_linkage.patch \
"

SRC_URI[md5sum] = "9a5978427c3841711f470e15343ca71f"
SRC_URI[sha256sum] = "d60cd9db59351d2b9cb19beb443170acaa28f073d13d258f67b3627635e32675"

FILES:${PN}:remove = "${datadir}/GraphicsMagick-1.3.33/config ${libdir}/GraphicsMagick-1.3.33/config"
FILES:${PN} += "${datadir}/GraphicsMagick-${PV}/config ${libdir}/GraphicsMagick-${PV}/config"

