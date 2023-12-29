require recipes-kernel/linux/linux-sunxi.inc

# define and use defconfig
do_configure_prepend() {
    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' .config
}

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "oka40i"
