
RDEPENDS:${PN}:append = " \
    opencv \
    opencv-dev \
    xsimd-dev \
    xtensor-bin \
    xtensor-bin-dev \
"

INSTALL_PKG_LISTS += " \
    opencv \
    ffmpeg-devel:real \
    ros-humble-ompl:real \
    ros-humble-image-transport:real \
    ros-humble-camera-info-manager:real \
    nlohmann-json-devel:real \
    git:real \
"
