# Note: that in the upstream original .bb file, PACKAGES already includes linux-firmware-rockchip-license.
# However, in yocto-meta-rockchip, linux-firmware-rockchip-license is added again in linux-firmware_%.bbappend.
# This is a bug that causes the following error:
# 
# ERROR: linux-firmware-1_20241017-r0 do_package: QA Issue: linux-firmware-rockchip-license is listed in
# PACKAGES multiple times, this leads to packaging errors. [packages-list]
# 
# Therefore, we need to deduplicate linux-firmware-rockchip-license here.

python() {
    packages = d.getVar("PACKAGES")
    packages = packages.replace("linux-firmware-rockchip-license", "")
    d.setVar("PACKAGES", packages + " linux-firmware-rockchip-license")
}
