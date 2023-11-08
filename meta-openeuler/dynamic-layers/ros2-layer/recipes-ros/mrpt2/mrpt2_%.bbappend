ROS_BUILD_DEPENDS:append = " \
        suitesparse \
"

ROS_EXEC_DEPENDS:append = " \
        suitesparse \
"

ROS_BUILD_DEPENDS:remove = " \
        suitesparse-cholmod \
        suitesparse-cxsparse \
"

ROS_EXEC_DEPENDS:remove = " \
        suitesparse-cholmod \
        suitesparse-cxsparse \
"
