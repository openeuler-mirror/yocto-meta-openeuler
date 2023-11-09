OPENEULER_LOCAL_NAME = "component_sensors"

PV = "0.17.1"

SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/uart/ola/depend/tf2_tools \
"

S = "${WORKDIR}/component_sensors/uart/ola/depend/tf2_tools"

DISABLE_OPENEULER_SOURCE_MAP = "1"

ROS_EXEC_DEPENDS:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', '', 'graphviz', d)}"

