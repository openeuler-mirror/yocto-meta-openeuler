# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included in live image

require recipes-core/images/bsp-${MACHINE}.inc

# all app and tools
IMAGE_INSTALL += " \
    ethercat-igh \
    libmodbus \
    openjpeg \
    opencv \
    oedeploy \
    ${@bb.utils.contains("DISTRO_FEATURES", "k8s", " \
    packagegroup-kubernetes-base \
    packagegroup-k8s-host \
    packagegroup-k8s-node \
    packagegroup-docker \
    packagegroup-oci \
    packagegroup-containerd \
    ", "", d)} \
"
