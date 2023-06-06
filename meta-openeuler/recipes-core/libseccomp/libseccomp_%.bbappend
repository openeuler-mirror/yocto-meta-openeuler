# meta-openeuler/recipes-core/libseccomp/libseccomp_2.5.3.bb

PV = "2.5.3"

SRC_URI_prepend = " \
        file://backport-bpf-pfc-Add-handling-for-0-syscalls-in-the-binary-tr.patch \
        file://backport-tests-Add-a-binary-tree-test-with-zero-syscalls.patch \
        file://backport-arch-disambiguate-in-arch-syscall-validate.patch \
"
