PV = "2.2.1"
OPENEULER_LOCAL_NAME = "hirobot_component_dtof"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/dtof_ros_demo/src/depth_image/depth_image_to_point_cloud \
"

S = "${WORKDIR}/hirobot_component_dtof/dtof_ros_demo/src/depth_image/depth_image_to_point_cloud"

DISABLE_OPENEULER_SOURCE_MAP = "1"

