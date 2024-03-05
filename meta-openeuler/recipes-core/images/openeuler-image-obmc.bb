# build an iso image, the live-os uses openeuler-image-live, it must be the same as itself(openeuler-image)
# when LIVE_ROOTFS_TYPE defined, bug may come out in poky, so just use default value ext4 in image-live.bbclass.
# notice we need MACHINE_FEATURES += "efi" in machine conf
IMAGE_FSTYPES:append:aarch64 = " iso"
IMAGE_FSTYPES:append:x86-64 = " iso"
IMAGE_FSTYPES:remove:raspberrypi4 = "iso"
INITRD_IMAGE_LIVE = "openeuler-image-live"

# notice: IMAGE_FEATURE configs such as IMAGE_FSTYPES should be defined before openeuler-image-common.inc(before core-image and image.bbclass)
require openeuler-image-common.inc

IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-base \
packagegroup-pam-plugins \
packagegroup-openssh \
"

# packages added to rootfs and target sdk
# put packages allowing a device to boot into "packagegroup-core-boot"
# put standard base packages to "packagegroup-core-base-utils"
# put extra base packages to "packagegroup-base"
# put other class of packages to "packagegroup-xxx"
#
# Notice:
#   IMAGE_INSTALL should define after openeuler-image-common.inc(after core-image\image.bbclass)
#   Generic packages are recommended to be defined in openeuler-image-common.inc.
#   If the package is related to a specific IMAGE_FEATURES or DISTRO_FEATURES,
#   it is recommended to add this via image.bb
IMAGE_INSTALL += " \
${@bb.utils.contains("DISTRO_FEATURES", "mcs", "packagegroup-mcs", "",d)} \
${@bb.utils.contains("DISTRO_FEATURES", "ros", "packagegroup-ros", "", d)} \
webui-vue \
systemd-analyze \
"

# You can add extra user here, suck like:
# inherit extrausers
# EXTRA_USERS_PARAMS = "useradd -p '' openeuler;"

inherit extrausers

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'obmc', 'obmc-phosphor-image', '', d)}

IMAGE_LINGUAS = ""

IMAGE_FEATURES += " \
    obmc-bmcweb \
"

XXX_FEATURES += " \
    obmc-bmc-state-mgmt \
    obmc-bmcweb \
    obmc-chassis-mgmt \
    obmc-chassis-state-mgmt \
    obmc-console \
    obmc-dbus-monitor \
    obmc-devtools \
    obmc-fan-control \
    obmc-fan-mgmt \
    obmc-flash-mgmt \
    obmc-fru-ipmi \
    obmc-health-monitor \
    obmc-host-ctl \
    obmc-host-ipmi \
    obmc-host-state-mgmt \
    obmc-ikvm \
    obmc-inventory \
    obmc-leds \
    obmc-logging-mgmt \
    obmc-remote-logging-mgmt \
    obmc-rng \
    obmc-net-ipmi \
    obmc-sensors \
    obmc-software \
    obmc-system-mgmt \
    obmc-user-mgmt \
    obmc-user-mgmt-ldap \
    ${@bb.utils.contains('DISTRO_FEATURES', 'obmc-ubi-fs', 'read-only-rootfs', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'phosphor-mmc', 'read-only-rootfs', '', d)} \
    ssh-server-dropbear \
    obmc-debug-collector \
    obmc-network-mgmt \
    obmc-settings-mgmt \
    obmc-telemetry \
    "

LICENSE = "Apache-2.0"


# The /etc/version file is misleading and not useful.  Remove it.
# Users should instead rely on /etc/os-release.
ROOTFS_POSTPROCESS_COMMAND += "remove_etc_version ; "

# The shadow recipe provides the binaries(like useradd, usermod) needed by the
# phosphor-user-manager.
ROOTFS_RO_UNNEEDED:remove = "shadow"

# bmc needs root users' home to be /home/root
ROOT_HOME = "/home/root"