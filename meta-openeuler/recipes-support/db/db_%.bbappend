# main bbfile: yocto-poky/meta/recipes-support/db/db_5.3.28.bb

# files, patches can't be applied in openeuler or conflict with openeuler
# patches that apply fail:
#     0001-atomic-Rename-local-__atomic_compare_exchange-to-avo.patch
SRC_URI_remove = " \
        https://download.oracle.com/berkeley-db/db-${PV}.tar.gz \
        file://0001-atomic-Rename-local-__atomic_compare_exchange-to-avo.patch \
"

# files, patches that come from openeuler
# patches that apply fail:
#     add-check-for-device-number-in-__check_lock_fn.patch
#     bugfix-fix-deadlock-on-mempool-file-locks.patch
#     db-1.85-errno.patch
#     db-5.3.28-condition-variable-ppc.patch
#     db-5.3.28-rpm-lock-check.patch
# patches that compile fail: "undefined reference to `__os_pthreads_timestamp'"
#     db-5.3.28-condition_variable.patch
SRC_URI_prepend = " \
        file://libdb/${BP}.tar.gz \
        file://libdb/007-mt19937db.c_license.patch \
        file://libdb/backport-CVE-2019-2708-Resolved-data-store-execution-which-led-to-partial-DoS.patch \
        file://libdb/checkpoint-opd-deadlock.patch \
        file://libdb/db-4.5.20-jni-include-dir.patch \
        file://libdb/db-4.6.21-1.85-compat.patch \
        file://libdb/db-5.3.21-memp_stat-upstream-fix.patch \
        file://libdb/db-5.3.21-mutex_leak.patch \
        file://libdb/db-5.3.28-atomic_compare_exchange.patch \
        file://libdb/db-5.3.28-cwd-db_config.patch \
        file://libdb/db-5.3.28-lemon_hash.patch \
        file://libdb/fix-a-potential-infinite-loop.patch \
        file://libdb/java8-fix.patch \
        file://libdb/libdb-5.3.21-region-size-check.patch \
        file://libdb/libdb-cbd-race.patch \
        file://libdb/libdb-limit-cpu.patch \
        file://libdb/libdb-multiarch.patch \
"
