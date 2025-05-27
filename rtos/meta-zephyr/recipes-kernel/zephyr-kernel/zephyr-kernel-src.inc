LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://zephyr-${ZEPHYR_VERSION}/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

CVE_PRODUCT = "zephyr"

inherit cmake

# all zephyr related applications share the same code base
OPENEULER_LOCAL_NAME = "zephyrproject"

# the dir holds all the zephyr project related source codes, e.g.
# zephyr kernel, zephyr modules, tools
ZEPHYR_PROJECT_DIR ?= "zephyr_project"
ZEPHYR_VERSION ?="3.7.1"

SRC_URI = "\
    file://lts3-zephyr-${ZEPHYR_VERSION}.tar.gz;subdir=zephyr_project \
    file://lts3-zephyr-modules-${ZEPHYR_VERSION}.tar.gz;subdir=zephyr_project \
    file://zephyr_openeuler_mcs.patch;patchdir=zephyr-${ZEPHYR_VERSION} \
    file://boards-xenvm-return-separate-defconfig-for-xenvm-wit.patch;patchdir=zephyr-${ZEPHYR_VERSION} \
"

# This file might be included from other places (like other layers) and not
# having an explicit path to the patches directory, will make bitbake fail to
# find the patch(es) in SRC_URI.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
S = "${WORKDIR}/zephyr_project"


# Zephyr modules should be in ${S} , add the modules you need
ZEPHYR_MODULES = "\
${S}/modules/lib/open-amp\;\
${S}/modules/hal/libmetal\;\
"
