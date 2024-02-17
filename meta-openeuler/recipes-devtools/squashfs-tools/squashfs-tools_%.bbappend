# main bbfile: yocto-poky/meta/recipes-devtools/squashfs-tools/squashfs-tools_git.bb

# version in openEuler
PV = "4.5.1"

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI = ""
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI =+ " \
        file://${BP}.tar.gz \
        "

SRC_URI[md5sum] = "edc3e14508f2716315787b9c88d163a1"
SRC_URI[sha256sum] = "277b6e7f75a4a57f72191295ae62766a10d627a4f5e5f19eadfbc861378deea7"
