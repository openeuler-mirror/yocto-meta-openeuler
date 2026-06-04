# bbfile: yocto-poky/meta/recipes-extended/time/time_1.9.bb

SRC_URI = "file://time-${PV}.tar.gz \
        file://add-help-opt.patch \
        file://time-1.9-sw.patch \
"

ASSUME_PROVIDE_PKGS = "time"
