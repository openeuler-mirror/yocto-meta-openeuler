# main bbfile: yocto-poky/meta/recipes-extended/screen/screen_4.8.0.bb

# files, patches that come from openeuler
SRC_URI_prepend = " \
        file://screen-4.3.1-crypt.patch \
        file://screen-4.3.1-screenrc.patch \
        file://screen-4.3.1-suppress_remap.patch \
        file://screen-E3.patch \
"
