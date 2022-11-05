# main bb file: yocto-poky/meta/recipes-support/fribidi/fribidi_1.0.10.bb

SRC_URI_prepend = "file://backport-CVE-2022-25308.patch \
                   file://backport-CVE-2022-25309.patch \
                   file://backport-CVE-2022-25310.patch \
                   "
