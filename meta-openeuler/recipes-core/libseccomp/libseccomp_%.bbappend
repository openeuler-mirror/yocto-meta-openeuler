# the main bb file: yocto-poky/meta/recipes-support/libseccomp/libseccomp_2.5.3.bb

PV = "2.5.4"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

# backport-api-fix-seccomp_export_bpf_mem-out-of-bounds.patch not in SP4, removed

S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "libseccomp"
