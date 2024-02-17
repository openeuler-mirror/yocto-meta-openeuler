# main bbfile: yocto-poky/meta/recipes-extended/libidn/libidn2_2.3.2.bb

# version in openEuler
PV = "2.3.3"

# solve lic check failed
LIC_FILES_CHKSUM:remove = " \
        file://src/idn2.c;endline=16;md5=e4b6d628a84a55f1fd8ae4c76c5f6509 \
        file://lib/idn2.h.in;endline=27;md5=d0fc8ec628be130a1d5b889107e92477 \
"

# files, patches that come from openeuler
SRC_URI:append = " \
        file://${BP}.tar.gz \
        file://bugfix-libidn2-change-rpath.patch \
"

SRC_URI[sha256sum] = "f3ac987522c00d33d44b323cae424e2cffcb4c63c6aa6cd1376edacbf1c36eb0"
