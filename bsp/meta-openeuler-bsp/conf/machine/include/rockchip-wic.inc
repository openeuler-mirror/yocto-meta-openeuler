WKS_FILE = "sdimage-opi.wks"

# enable extlinux.conf auto-generation
UBOOT_EXTLINUX = "1"
UBOOT_EXTLINUX_KERNEL_IMAGE = "/${KERNEL_IMAGETYPE}"
UBOOT_EXTLINUX_FDT = "/${ROCKCHIP_KERNEL_DTB_NAME}"

# only used by UBOOT_EXTLINUX_CONSOLE
RK_CONSOLE_BAUD ?= "${@d.getVar('SERIAL_CONSOLES').split(';')[0]}"
RK_CONSOLE_DEVICE ?= "${@d.getVar('SERIAL_CONSOLES').split(';')[1].split()[0]}"

UBOOT_EXTLINUX_CONSOLE ?= "console=${RK_CONSOLE_DEVICE},${RK_CONSOLE_BAUD} console=tty1"

# Install the files for boot partition
# Note: the ROCKCHIP_KERNEL_DTB_NAME must be the same as fdt in extlinux.conf
IMAGE_BOOT_FILES = " \
        ${KERNEL_IMAGETYPE} \
        ${ROCKCHIP_KERNEL_DTB_NAME} \
        "
