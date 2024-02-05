OPENEULER_LOCAL_NAME = "hirobot_component_dtof"

PV = "2.3.1"

SRC_URI = " \
    file://hirobot_component_dtof/dtof_ros_demo/src/depth_image/depthimage_to_laserscan \
"

S = "${WORKDIR}/hirobot_component_dtof/dtof_ros_demo/src/depth_image/depthimage_to_laserscan"

DISABLE_OPENEULER_SOURCE_MAP = "1"

