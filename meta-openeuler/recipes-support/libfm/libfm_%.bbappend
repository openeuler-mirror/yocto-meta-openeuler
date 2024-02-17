# main bb: yocto-poky/meta/recipes-support/libfm/libfm_1.3.2.bb

PV = "1.3.2"

# can't apply from src-openeuler:
# libfm-1.3.2-0001-fm_config_load_from_key_file-don-t-replace-string-va.patch
# libfm-1.3.0.2-moduledir-gtkspecific-v03.patch
SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"
