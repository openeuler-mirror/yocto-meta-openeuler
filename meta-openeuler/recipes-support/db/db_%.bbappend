# main bbfile: yocto-poky/meta/recipes-support/db/db_5.3.28.bb
OPENEULER_REPO_NAME = "libdb"

# files, patches can't be applied in openeuler or conflict with openeuler
# patches that apply fail:
#     0001-atomic-Rename-local-__atomic_compare_exchange-to-avo.patch
SRC_URI:remove = "file://0001-atomic-Rename-local-__atomic_compare_exchange-to-avo.patch \
"

# files, patches that come from openeuler
# patches that apply fail:
#     db-1.85-errno.patch for db.1.85.tar.gz
# patches that compile fail: "undefined reference to `__os_pthreads_timestamp'"
#     db-5.3.28-condition_variable.patch
#     db-5.3.28-condition-variable-ppc.patch 
#     db-5.3.28-rpm-lock-check.patch 
#     add-check-for-device-number-in-__check_lock_fn.patch
SRC_URI:append = "\
    file://db-${PV}.tar.gz \
    file://libdb-multiarch.patch \
    file://db-4.6.21-1.85-compat.patch \
    file://db-4.5.20-jni-include-dir.patch \
    file://007-mt19937db.c_license.patch \
    file://java8-fix.patch \
    file://db-5.3.21-memp_stat-upstream-fix.patch \
    file://db-5.3.21-mutex_leak.patch \
    file://db-5.3.28-lemon_hash.patch \
    file://db-5.3.28-cwd-db_config.patch \
    file://libdb-5.3.21-region-size-check.patch \
    file://checkpoint-opd-deadlock.patch \
    file://db-5.3.28-atomic_compare_exchange.patch \
    file://backport-CVE-2019-2708-Resolved-data-store-execution-which-led-to-partial-DoS.patch \
    file://bugfix-fix-deadlock-on-mempool-file-locks.patch \
    file://libdb-limit-cpu.patch \
    file://fix-a-potential-infinite-loop.patch \
    file://db-5.3.28-sw.patch \
"
