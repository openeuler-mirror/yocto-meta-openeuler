inherit ros_distro_humble

SRC_URI = " \
   file://qhull-lib64.patch \
   file://qhull-staticr-pic.patch \
"

S = "${WORKDIR}/qhull-2020.2"
