# kernel-dev Configuration

IMAGE_INSTALL += " flex bison kernel-devsrc "

fakeroot install_kernel_devsrc() {
    rpm -ivh --dbpath /var/lib/rpm --nosignature --root ${IMAGE_ROOTFS} --nodeps --ignorearch \
    ${DEPLOY_DIR_RPM}/${MACHINE_ARCH}/kernel-devsrc-${PV}-${PR}.${MACHINE_ARCH}.rpm --force

    RC_LOCAL="${IMAGE_ROOTFS}/etc/rc.local"
    DELETE_LINE="!===="

    if [ ! -f "${RC_LOCAL}" ]; then
    cat > "${RC_LOCAL}" << EOF
#!/bin/bash
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

EOF
    chmod +x "${RC_LOCAL}"
    fi

    echo "pushd /lib/modules/*-openeuler/build && make modules_prepare && popd  # ${DELETE_LINE}" >> ${RC_LOCAL}
    echo "sed -i '/${DELETE_LINE}$/d' /etc/rc.local # ${DELETE_LINE}" >> ${RC_LOCAL}
}

ROOTFS_POSTPROCESS_COMMAND:append = "install_kernel_devsrc;"
