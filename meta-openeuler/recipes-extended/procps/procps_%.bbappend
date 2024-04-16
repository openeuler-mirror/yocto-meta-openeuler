#main bbfile: yocto-poky/meta/recipes-extended/procps/procps_3.3.17.bb

#version in openEuler
PV = "4.0.4"

S = "${WORKDIR}/procps-ng-${PV}"

FILESEXTRAPATHS:append := "${THISDIR}/procps/:"

OPENEULER_REPO_NAME = "procps-ng"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            file://0001-w.c-correct-musl-builds.patch \
            file://0002-proc-escape.c-add-missing-include.patch \
            "
# files, patches that come from openeuler
SRC_URI += " \
        file://procps-ng/procps-ng-${PV}.tar.xz \
        file://openeuler-add-M-and-N-options-for-top.patch \
        file://openeuler-top-exit-with-error-when-pid-overflow.patch \
        file://backport-library-address-remaining-cpu-distortions-stat-api.patch \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.LIB;md5=4cf66a4984120007c9881cc871cf49db \
                    "

# file://procps-ng/openeuler-add-M-and-N-options-for-top.patch
# file://procps-ng/openeuler-top-exit-with-error-when-pid-overflow.patch
# file://procps-ng/skill-Restore-the-p-flag-functionality.patch
do_configure:prepend() {
    # cannot run po/update-potfiles in new version
    if [ ! -f ${S}/po/update-potfiles ]; then
        touch ${S}/po/update-potfiles
        chmod +x ${S}/po/update-potfiles
    fi
}

SRC_URI[sha256sum] = "ee3fcd2ea6ff94aa43a81ba5cc7912b7c9615acd2911c7a3d3ea081287fdf47a"
