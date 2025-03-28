SUMMARY = "container os image"
# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES is recommended to be defined before openeuler-image-common.inc, 
# because openeuler-image-common.inc inlcude core-image.bbclass, and image.bbclass in core-image.bbclass
# will traverse the type of IMAGE_FSTYPES to include the image-${FSTYPE}.class corresponding to the type,
# so if we have special IMAGE_FSTYPES, such as live, IMAGE_FSTYPES needs to be clearly defined in advance,
# otherwise, the following error will occur:
#   No IMAGE_CMD defined for IMAGE_FSTYPES entry 'xxx' - possibly invalid type name or missing support class
# Here we provide configuration file image-early-config-${MACHINE}.inc to accommodate the variables that need
# to be defined in advance as mentioned above
include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

inherit features_check
REQUIRED_DISTRO_FEATURES = "isulad"

# IMAGE_INSTALL was defined in file openeuler-image-common.inc
# overwrite this variable to remove unnecessary packages
# this image is only used to start containers
# Thus, keep the following packages:
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-kernel-modules \
${@bb.utils.contains("DISTRO_FEATURES", "kubeedge isulad", "packagegroup-kubeedge", "", d)} \
packagegroup-isulad \
packagegroup-container-images \
"

# Generate virtual disk image other than init ram fs for qemu because:
# 1. the rootfs is too large with the container image file inside it
#    exceeding the maximum size of the init ram fs.
# 2. when loading and starting the container, 
#    it takes extra spaces as the container image files unpacked
#    and new contaniers created, so we need an expandable rootfs.
# 3. the virtual disk image can be reused and resized.
IMAGE_FSTYPES:qemu-aarch64 = "wic.bz2"
WKS_FILE:qemu-aarch64 = "virtdisk-qemu.wks" 

# It's a pity that the indentation of the following "here document" codes 
# looks wired. However, it is unavoidable because the codes are used to
# append commands to the file /etc/profile in the rootfs, and if we
# indent them "correctly", the commands will be indented in the file,
# which looks wired as well. To make the style normal in destination
# file, we have to make the indentation wired here.
# The indentation of the word "EOF" is important, do not change it.
do_auto_start_container() {
	cat <<'EOF' >> ${IMAGE_ROOTFS}/${sysconfdir}/profile
# these commands are used to load openeuler 23.09 image and start the container
container_name="openeuler-container"
# loading image costs time, so we only load it when the image has not been loaded
if [ -z "$(isula images -q -f reference=openeuler/openeuler:23.09)" ];then
	echo "Loading openeuler 23.09 image ..."
	isula load -i /containers/isula-oe-23.09-image.tar
fi
# if the container is created, reuse it
if [ -z "$(isula ps -a -q -f name=$container_name)" ]; then
	echo "Starting the container ..."
	isula run -it --net=host --name=${container_name} openeuler/openeuler:23.09 sh
else                                                        
	echo "Starting the container ..."
	isula start ${container_name}
	isula attach ${container_name}
fi
EOF
}

addtask auto_start_container after do_rootfs before do_image
