include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

# not build sdk
deltask populate_sdk

DEPENDS = "linux-openeuler busybox run-postinsts"
RDEPENDS = ""
PACKAGE_INTALL = "kernel-img busybox musl"
# origin set is packagegroup-core-ssh-openssh
FEATURE_INSTALL = ""
# we don't need extra users
EXTRA_USERS_PARAMS = ""

IMAGE_INSTALL = " \
    kernel-img \
    busybox \
    musl \
"

create_other_directory() {
    cd "${IMAGE_ROOTFS}"
    mv linuxrc init
    mkdir -p {dev,proc,sys,tmp,run}
    # delete etc 
    rm -rf etc/*
    mkdir -p etc/init.d
    cat > etc/init.d/rcS <<EOF
#! /bin/sh

/bin/mount -a
mount -o remount, rw /
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
mdev -s
EOF
    chmod +x etc/init.d/rcS

    cat > etc/fstab <<EOF
proc            /proc   proc    defaults    0   0
tmpfs           /tmp    tmpfs   defaults    0   0
sysfs           /sys    sysfs   defaults    0   0
EOF
    chmod +x etc/fstab

    cat > etc/profile <<EOF
# /etc/profile: system-wide .profile file for the Bourne shells

echo
echo -n "Processing /etc/profile... "
# no-op
echo "Done"
echo
EOF
    cd -
}
IMAGE_PREPROCESS_COMMAND += "create_other_directory;"
