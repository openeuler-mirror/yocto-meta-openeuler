# main bbfile: yocto-poky/meta/recipes-support/numactl/numactl_git.bb

S = "${WORKDIR}/${BP}"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://0001-libnuma-clear-errno-at-the-end-of-numa_init.patch \
    file://0002-numactl-Fix-shm-verfiy-for-preferred-policy.patch \
    file://0003-numactl-numactl-length-xxx-shm-xxx-px-doesn-t-work.patch \
    file://0004-fix-wrong-nodemask_sz-when-CONFIG_NODES_SHIFT-is-les.patch \
    file://0005-numactl.c-Remove-unused-variable.patch \
    file://0006-numactl.c-Fix-merging-of-neighboring-pages-policies-.patch \
    file://0007-shm.c-Replace-stat64-fstat64-ftruncate64mmap64-with-.patch \
    file://0008-numastat-Update-system-hugepages-memory-info-from-sy.patch \
    file://0009-riscv64-remove-flag-latomic.patch \
    file://0010-fix-fix-memory-leaks-when-run-with-H.patch \
    file://0011-libnuma-Fix-unexpected-output.patch \
    file://0012-libnuma-Fix-incorrect-print-and-exit-of-numa_preferr.patch \
    file://0013-fix-the-using-of-the-uninitialized-value.patch \
"
