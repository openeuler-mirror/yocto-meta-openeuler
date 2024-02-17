# main bbfile: yocto-poky/meta/recipes-extended/bzip2/bzip2_1.0.8.bb

PV = "1.0.8"

LIC_FILES_CHKSUM = "file://LICENSE;beginline=4;endline=37;md5=600af43c50f1fcb82e32f19b32df4664 \
                    file://${S}/LICENSE;md5=1e5cffe65fc786f83a11a4b225495c0b \
"

# patches in openeuler
SRC_URI:append = " \
    file://${BP}.tar.gz \
    file://0001-add-compile-option.patch \
    file://0002-CVE-2019-12900.patch \
"
