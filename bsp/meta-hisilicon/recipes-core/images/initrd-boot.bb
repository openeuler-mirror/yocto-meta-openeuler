# no host package
TOOLCHAIN_HOST_TASK = ""
 
SUMMARY = "Simple initramfs image. Mostly used for live images"

# we want a non systemd init manager, packagegroup-core-boot-live is for it.
VIRTUAL-RUNTIME_base-utils = "packagegroup-core-boot-live"
PACKAGE_INSTALL = " \
        ${VIRTUAL-RUNTIME_base-utils} \
        base-passwd \
        ${ROOTFS_BOOTSTRAP_INSTALL} \
        packagegroup-kernel-modules \
        imagetools-hi3093 \
        kernel-module-ksecurec \ 
        kernel-module-log-drv \ 
        kernel-module-comm-drv \ 
        kernel-module-mdio-drv \ 
        kernel-module-msg-scm3-drv \ 
        kernel-module-usb-common \ 
        kernel-module-udc-core \ 
        kernel-module-configfs \ 
        kernel-module-libcomposite \ 
        kernel-module-usb-drv \
        kernel-module-dwc3 \
        kernel-module-hw-lock-drv \ 
        kernel-module-mmc-core \ 
        kernel-module-mmc-block \ 
        kernel-module-emmc-drv \ 
        kernel-module-sdio-drv \ 
        kernel-module-localbus-drv \ 
        kernel-module-devmem-drv \ 
        glib-2.0 \
        libpcre2 \
        libtirpc \
        readline \
        ncurses-dev \
"
 
export IMAGE_BASENAME = "initrd-boot"
 
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
 
# make install or nologin when using busybox-inittab
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -e ./etc/inittab ];then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
        mkdir -p ./mnt/newroot
        
        if [ -d ./tools-tmp ];then
            cp -f ./tools-tmp/init ./init
            cp -f ./tools-tmp/bin/* ./bin
            rm -rf ./tools-tmp
        fi

        rm -f ./linuxrc || true
        rm -f ./usr/sbin/grub* || true

        if [ -d ./lib/modules/hi3093 ];then
            mkdir -p ./lib/net
            mv ./lib/modules/hi3093/* ./lib/net
        fi

        dels="./boot ./usr/bin ./usr/games ./usr/include ./usr/lib ./usr/libexec ./usr/share ./lib/depmod.d ./lib/modprobe.d ./lib/modules ./opt"
        for dird in $dels
        do
            if [ -d $dird ];then
                rm -rf $dird
            fi
        done

    fi
    
    cd -
}
 
IMAGE_FEATURES:append = " empty-root-password" 
require recipes-core/images/openeuler-image-common.inc                                                                     
