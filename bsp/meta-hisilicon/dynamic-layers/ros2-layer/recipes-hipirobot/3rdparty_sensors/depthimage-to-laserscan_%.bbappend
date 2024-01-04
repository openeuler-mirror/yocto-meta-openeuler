OPENEULER_LOCAL_NAME = "hieuler_3rdparty_sensors"

PV = "2.3.1"

SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/depth_image/depthimage_to_laserscan \
"

S = "${WORKDIR}/hieuler_3rdparty_sensors/depth_image/depthimage_to_laserscan"

DISABLE_OPENEULER_SOURCE_MAP = "1"

