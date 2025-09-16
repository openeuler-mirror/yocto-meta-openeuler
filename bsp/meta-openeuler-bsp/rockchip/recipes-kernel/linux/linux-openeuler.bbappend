require recipes-kernel/linux/linux-rockchip.inc
include recipes-kernel/linux/linux-${MACHINE}.inc

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|tspi-3566|ryd-3568|ok3588|ok3399|orangepi4-lts|roc-rk3588s-pc|orangepi5"
