# main bbfile: yocto-poky/meta/recipes-extended/libidn/libidn2_2.3.2.bb

# version in openEuler
PV = "2.3.4"

# solve lic check failed for 2.3.4 vs base recipe 2.3.7
LIC_FILES_CHKSUM:remove = " \
        file://src/idn2.c;endline=16;md5=afc1531bda991ba6338e33a7eff758a0 \
        file://lib/idn2.h.in;endline=27;md5=f88d218005a5c45b68a83cecb5bd7f26 \
"
LIC_FILES_CHKSUM:append = " \
        file://src/idn2.c;endline=16;md5=0f347a5b17acf44440bf53e406f1df70 \
        file://lib/idn2.h.in;endline=27;md5=4d7b3771faa9c60067ed1da914508bc5 \
"

# files, patches that come from openeuler
SRC_URI:append = " \
        file://${BP}.tar.gz \
        file://bugfix-libidn2-change-rpath.patch \
"

SRC_URI[sha256sum] = "f3ac987522c00d33d44b323cae424e2cffcb4c63c6aa6cd1376edacbf1c36eb0"
