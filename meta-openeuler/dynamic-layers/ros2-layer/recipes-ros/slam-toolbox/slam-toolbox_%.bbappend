# openeuler embedded just want runtime tool/library, not include ground station like rviz

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
SRC_URI:prepend = " \
        file://0-slam-toolbox-fix-can-not-find-tbb.patch \
        file://1-remove-rviz.patch \
        "
# this fix: rosidl_write_generator_arguments() must be invoked with at least one of the xxx
ROS_BUILD_DEPENDS:append = " rosidl-typesupport-fastrtps-cpp rosidl-typesupport-fastrtps-c"
ROS_BUILDTOOL_DEPENDS:append = " rosidl-default-generators-native rosidl-typesupport-fastrtps-cpp-native rosidl-typesupport-fastrtps-c-native"
ROS_EXPORT_DEPENDS:append = " ceres-solver"
ROS_EXEC_DEPENDS:append = " rosidl-typesupport-fastrtps-cpp rosidl-typesupport-fastrtps-c"
ROS_EXEC_DEPENDS:remove = "ceres-solver"

FILES:${PN}-dev += "${datadir}/karto_sdk ${datadir}/solver_plugins.xml"

ROS_EXEC_DEPENDS:remove += " \
        qtbase \
        rviz-common \
        rviz-ogre-vendor \
        rviz-default-plugins \
        rviz-rendering \
"

ROS_BUILD_DEPENDS:remove += " \
        qtbase \
        rviz-common \
        rviz-ogre-vendor \
        rviz-default-plugins \
        rviz-rendering \
"

ROS_EXPORT_DEPENDS:remove += " \
        rviz-common \
        rviz-ogre-vendor \
        rviz-default-plugins \
        rviz-rendering \
"


