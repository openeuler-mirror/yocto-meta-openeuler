# meta-openeuler/recipes-core/libseccomp/libseccomp_2.5.3.bb

PV = "2.5.4"

SRC_URI_prepend = "file://backport-arch-disambiguate-in-arch-syscall-validate.patch \
"