PV = "2.2.1"
OPENEULER_LOCAL_NAME = "hieuler_3rdparty_sensors"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/depth_image/depth_image_to_point_cloud \
"

S = "${WORKDIR}/hieuler_3rdparty_sensors/depth_image/depth_image_to_point_cloud"

DISABLE_OPENEULER_SOURCE_MAP = "1"

