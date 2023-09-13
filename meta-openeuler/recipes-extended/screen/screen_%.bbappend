# main bbfile: yocto-poky/meta/recipes-extended/screen/screen_4.9.0.bb

PV = "4.9.0"

SRC_URI:remove = "file://CVE-2023-24626.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = "file://screen-4.3.1-screenrc.patch \
           file://screen-E3.patch \
           file://screen-4.3.1-suppress_remap.patch \
           file://screen-4.3.1-crypt.patch \
           file://backport-CVE-2023-24626.patch \
"

SRC_URI[sha256sum] = "a7d615ee46f5361489fc423c4436b02d5b622aeefadeb4cd1a60b46d5d161dde"
