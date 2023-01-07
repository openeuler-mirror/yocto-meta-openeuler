inherit ros_distro_foxy

PV="1.10.1"

# compiling the pcl library requires a lot of memory and other resources, 
# so multiple threads at the same time will cause a crash due to lack of resources,
# as a work around, it is restricted here.
OECMAKE_TARGET_COMPILE += " -j 2 "
