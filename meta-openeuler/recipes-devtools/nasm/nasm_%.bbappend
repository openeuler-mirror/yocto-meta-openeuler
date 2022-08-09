# main bbfile: yocto-poky/meta/recipes-devtools/nasm/nasm_2.15.05.bb

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://enable-make-check.patch \
"
