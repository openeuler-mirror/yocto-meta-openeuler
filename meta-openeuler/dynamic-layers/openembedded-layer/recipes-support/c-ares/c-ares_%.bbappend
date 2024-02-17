# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/c-ares/c-ares_1.18.1.bb

# version in openEuler
PV = "1.19.1"
S = "${WORKDIR}/${BP}"

# files, patches can't be applied in openeuler or conflict with openeuler
# this patch no need for 1.19.1
SRC_URI:remove = " \
    file://CVE-2022-4904.patch \
    file://CVE-2023-31130.patch \
    file://CVE-2023-32067.patch \
"

#file://0001-Lower-init-prio-for-extension-attributes.patch 

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://0000-Use-RPM-compiler-options.patch \
    file://backport-disable-live-tests.patch \
"
