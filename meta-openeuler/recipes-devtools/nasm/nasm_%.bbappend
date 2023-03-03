# main bbfile: yocto-poky/meta/recipes-devtools/nasm/nasm_2.15.05.bb
OPENEULER_BRANCH = "openEuler-23.03"

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://enable-make-check.patch \
        file://fix-help-info-error.patch \
"
