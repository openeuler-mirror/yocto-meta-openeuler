ROS_BUILD_DEPENDS:remove = " git "

# add openeuler patch
SRC_URI:append = " \
        file://cartographer-adapt-eigen.patch \
        file://cartographer-adapt-absl.patch \
        "
