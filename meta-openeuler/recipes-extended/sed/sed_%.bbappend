# main bbfile: yocto-poky/meta/recipes-extended/sed/sed_4.8.bb

# patches in openeuler
SRC_URI += " \
           file://sed/backport-sed-c-flag.patch \
           file://sed/backport-sed-handle-very-long-execution-lines-tiny-change.patch \
           file://sed/backport-sed-handle-very-long-input-lines-with-R-tiny-change.patch \
"
