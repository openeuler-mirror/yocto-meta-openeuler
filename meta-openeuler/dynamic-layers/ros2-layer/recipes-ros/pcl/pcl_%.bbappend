inherit ros_distro_humble

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
        file://pcl-1.12.0-metslib.patch \
        file://pcl-1.12.0-fedora.patch \
        file://pcl-1.12.1-boost.patch \
        file://00-pcl-fix-pcl-root.patch \
        "

# compiling the pcl library requires a lot of memory and other resources, 
# so multiple threads at the same time will cause a crash due to lack of resources,
# as a work around, it is restricted here.
OECMAKE_TARGET_COMPILE += " -j 2 "
