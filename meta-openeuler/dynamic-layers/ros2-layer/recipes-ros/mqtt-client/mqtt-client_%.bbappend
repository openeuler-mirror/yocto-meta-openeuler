# the main bb file: yocto-meta-openeuler/meta-openeuler/dynamic-layers/ros2-layer/recipes-ros/mqtt-client/mqtt-client_2.3.0-1.bb
inherit oee-archive

PV = "2.3.0"

SRC_URI:prepend = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}-interfaces/ros-humble-${BPN}_${PV}.orig.tar.gz \
"

S = "${WORKDIR}/ros-humble-${BP}"

#| /home/openeuler/build/qemu-aarch64/tmp/work/aarch64-openeuler-linux/mqtt-client/2.3.0-1-r0/recipe-sysroot/usr/include/rclcpp/rclcpp/logging.hpp:955:5: note: in expansion of macro 'RCUTILS_LOG_WARN_NAMED'
#|   955 |     RCUTILS_LOG_WARN_NAMED( \
#|       |     ^~~~~~~~~~~~~~~~~~~~~~
#| /home/openeuler/build/qemu-aarch64/tmp/work/aarch64-openeuler-linux/mqtt-client/2.3.0-1-r0/mqtt_client-release-release-iron-mqtt_client/src/MqttClient.ros2.cpp:1368:5: note: in expansion of macro 'RCLCPP_WARN'
#|  1368 |     RCLCPP_WARN(get_logger(),
#|       |     ^~~~~~~~~~~
#| cc1plus: some warnings being treated as errors
#| ninja: build stopped: subcommand failed.

SECURITY_STRINGFORMAT = ""
