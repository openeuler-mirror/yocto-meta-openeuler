# main bbfile: yocto-poky/meta/recipes-extended/bzip2/bzip2_1.0.8.bb

# patches in openeuler
SRC_URI_append = " \
           file://0001-add-compile-option.patch \
           file://0002-CVE-2019-12900.patch \
"
