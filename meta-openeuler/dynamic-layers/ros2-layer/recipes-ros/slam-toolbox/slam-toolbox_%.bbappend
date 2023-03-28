# openeuler embedded just want runtime tool/library, not include ground station like rviz

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

