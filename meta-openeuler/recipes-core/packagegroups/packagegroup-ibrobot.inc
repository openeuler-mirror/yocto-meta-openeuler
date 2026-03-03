
RDEPENDS:${PN}:append = " \
    opencv \
    opencv-dev \
    xsimd-dev \
    xtensor-bin \
    xtensor-bin-dev \
"

INSTALL_PKG_LISTS += " \
    opencv \
    ros-humble-ompl:real \
"
