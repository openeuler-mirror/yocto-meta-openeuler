inherit ros_distro_humble

SRC_URI = " \
   file://qhull-lib64.patch \
   file://qhull-staticr-pic.patch \
"

S = "${WORKDIR}/qhull-2020.2"

# In this version (2020.2), the binary files under /usr/bin directory
# are referenced by pcl, so bindir needs to be added to SYSROOT_DIRS.
SYSROOT_DIRS += " ${bindir} "
