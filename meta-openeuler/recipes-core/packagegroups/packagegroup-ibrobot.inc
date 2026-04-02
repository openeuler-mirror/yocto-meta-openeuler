
RDEPENDS:${PN}:append = " \
    opencv \
    opencv-dev \
    xsimd-dev \
    xtensor-bin \
    xtensor-bin-dev \
"

INSTALL_PKG_LISTS += " \
    opencv \
    ffmpeg:real \
    ffmpeg-devel:real \
    ros-humble-ompl:real \
    ros-humble-image-transport:real \
    ros-humble-camera-info-manager:real \
    ros-humble-hardware-interface:real \
    nlohmann-json-devel:real \
    git:real \
"
