# the main bb file: yocto-poky/meta/recipes-support/libseccomp/libseccomp_2.5.3.bb

PV = "2.5.4"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://backport-arch-disambiguate-in-arch-syscall-validate.patch \
    file://Add-64-bit-LoongArch-support.patch \
    file://fix-build-error-for-libseccomp.patch \
    file://fix_undefined_behavior_in_scmp_bpf_sim.patch \
"

S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "libseccomp"
