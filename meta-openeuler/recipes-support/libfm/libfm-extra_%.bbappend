# main bb: yocto-poky/meta/recipes-support/libfm/libfm-extra_1.3.2.bb

OPENEULER_LOCAL_NAME = "libfm"

PV = "1.3.2"

# can't apply from src-openeuler:
# libfm-1.3.2-0001-fm_config_load_from_key_file-don-t-replace-string-va.patch
# libfm-1.3.0.2-moduledir-gtkspecific-v03.patch
SRC_URI += " \
        file://libfm-${PV}.tar.xz \
"

S = "${WORKDIR}/libfm-${PV}"
