inherit openeuler_ros_source

# EXTRA_OECMAKE += "-UPYTHON_EXECUTABLE" is not work in meta-ros-common/recipes-extended/libflann/libflann_1.9.1.bb, fixed it.
EXTRA_OECMAKE_remove += "-UPYTHON_EXECUTABLE"
EXTRA_OECMAKE += " -DPYTHON_EXECUTABLE=0 "
