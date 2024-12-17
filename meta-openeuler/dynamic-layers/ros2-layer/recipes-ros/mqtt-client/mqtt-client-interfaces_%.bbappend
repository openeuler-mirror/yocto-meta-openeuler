# the main bb file: yocto-meta-openeuler/meta-openeuler/dynamic-layers/ros2-layer/recipes-ros/mqtt-client/mqtt-client-interfaces_2.3.0-1.bb
inherit oee-archive

ROS_BUILDTOOL_DEPENDS += " \
    rosidl-default-generators-native \
"
