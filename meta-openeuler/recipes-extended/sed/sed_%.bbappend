# main bbfile: yocto-poky/meta/recipes-extended/sed/sed_4.8.bb

# patches in openeuler
SRC_URI_append += " \
           file://sed/backport-sed-c-flag.patch \
           file://sed/backport-sed-handle-very-long-execution-lines-tiny-change.patch \
           file://sed/backport-sed-handle-very-long-input-lines-with-R-tiny-change.patch \
"

SRC_URI[md5sum] = "6d906edfdb3202304059233f51f9a71d"
SRC_URI[sha256sum] = "f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633"
