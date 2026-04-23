
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
    ros-humble-ros2-control:real \
    ros-humble-ros2-controllers:real \
    ros-humble-joint-state-publisher-gui:real \
    ros-humble-rviz2:real \
    ros-humble-xacro:real \
    ros-humble-usb-cam:real \
    ros-humble-realsense2-camera:real \
    ros-humble-cv-bridge:real \
    ros-humble-controller-manager:real \
    ros-humble-joint-state-publisher:real \
    ros-humble-controller-manager-msgs:real \
    ros-humble-moveit-msgs:real \
    ros-humble-moveit:real \
    ros-humble-moveit-configs-utils:real \
    ros-humble-moveit-planners-ompl:real \
    ros-humble-moveit-planners-chomp:real \
    ros-humble-moveit-servo:real \
    ros-humble-rosbridge-library:real \
    python3-websockets:real \
    nlohmann-json-devel:real \
    ros-humble-rosbag2-storage-mcap:real \
    python3-pyserial:real \
    python3-scipy:real \
    cmake:real \
    gcc:real \
    gcc-c++:real \
    make:real \
    git:real \
"
