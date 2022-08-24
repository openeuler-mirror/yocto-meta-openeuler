# main bbfile: yocto-poky/meta/recipes-devtools/squashfs-tools/squashfs-tools_git.bb

#version in openEuler
PV = "4.5"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            git://github.com/plougher/squashfs-tools.git;protocol=https \
            git://github.com/plougher/squashfs-tools.git;protocol=https;branch=master \
            file://0001-squashfs-tools-fix-build-failure-against-gcc-10.patch;striplevel=2 \
            file://CVE-2021-40153.patch;striplevel=2 \
            file://CVE-2021-41072-requisite-1.patch;striplevel=2 \
            file://CVE-2021-41072-requisite-2.patch;striplevel=2 \
            file://CVE-2021-41072-requisite-3.patch;striplevel=2 \
            file://CVE-2021-41072.patch;striplevel=2 \
            "

S = "${WORKDIR}/${BP}"
B = "${S}/${PN}"

# files, patches that come from openeuler
SRC_URI += " \
        file://squashfs4.5.tar.gz \
        file://0001-CVE-2021-41072.patch \
        file://0002-CVE-2021-41072.patch \
        file://0003-CVE-2021-41072.patch \
        file://0004-CVE-2021-41072.patch \
        file://0005-CVE-2021-41072.patch \
        "

