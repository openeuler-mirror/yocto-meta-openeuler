# main bb: yocto-poky/meta/recipes-multimedia/sbc/sbc_1.5.bb

PV = "2.2"

# license headers changed in 2.2
LIC_FILES_CHKSUM = "file://src/sbcenc.c;beginline=1;endline=24;md5=1db4f3850f47b59e79aeedb2668f4b3e \
                    file://sbc/sbc.h;beginline=1;endline=26;md5=c5a50a7fc33c148ee362e2b46574a87f \
"

# no need for 2.0
SRC_URI:remove = " \
        file://0001-sbc_primitives-Fix-build-on-non-x86.patch \
"

SRC_URI:prepend = " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"
