OPENEULER_LOCAL_NAME = "3rdparty_sensors"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/lidar/eai_lidar \
"

S = "${WORKDIR}/3rdparty_sensors/lidar/eai_lidar"

SRC_URI:remove = " \
    file://00-ydlidar-ros2-driver-fix-error.patch \
"

