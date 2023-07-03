#main bbfile: yocto-poky/meta/recipes-extended/procps/procps_3.3.17.bb

#version in openEuler
PV = "4.0.2"

S = "${WORKDIR}/procps-ng-${PV}"

FILESEXTRAPATHS:append := "${THISDIR}/procps/:"

OPENEULER_REPO_NAME = "procps-ng"

# files, patches can't be applied in openeuler or conflict with openeuler
# files, patches that come from openeuler
SRC_URI:append = " \
        file://procps-musl.patch \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.LIB;md5=4cf66a4984120007c9881cc871cf49db \
                    "

SRC_URI[sha256sum] = "ee3fcd2ea6ff94aa43a81ba5cc7912b7c9615acd2911c7a3d3ea081287fdf47a"
