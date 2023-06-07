PV = "3.3"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_prepend = "file://${BP}.tar.gz \
        file://fix-fixfiles-N-date-function.patch;patchdir=.. \
        file://fix-fixfiles-N-date-function-two.patch;patchdir=.. \
        file://backport-policycoreutils-handle-argument-counter-of-zero.patch;patchdir=.. \
        file://backport-newrole-check-for-crypt-3-failure.patch;patchdir=.. \
        file://backport-newrole-ensure-password-memory-erasure.patch;patchdir=.. \
        file://backport-semodule_package-Close-leaking-fd.patch;patchdir=.. \
        file://backport-python-Split-semanage-import-into-two-transactions.patch;patchdir=.. \
        file://backport-python-audit2allow-close-file-stream-on-error.patch;patchdir=.. \
        file://backport-python-Do-not-query-the-local-database-if-the-fcontext-is-non-local.patch;patchdir=.. \
        file://backport-fixfiles-Unmount-temporary-bind-mounts-on-SIGINT.patch;patchdir=.. \
        file://backport-sepolicy-Call-os.makedirs-with-exist_ok-True.patch;patchdir=.. \
        file://backport-policycoreutils-fix-potential-NULL-reference-in-load_checks.patch;patchdir=.. \
        file://backport-python-sepolicy-add-missing-booleans-to-man-pages.patch;patchdir=.. \
        file://backport-python-sepolicy-Cache-conditional-rule-queries.patch;patchdir=.. \
        "

SRC_URI[md5sum] = "f2d555505dfcf13a89144306d4bc5bdc"
SRC_URI[sha256sum] = "7dc28e398afab9e917f02ce23dc93aff817f79171550e88bc743e31cde26f936"

S = "${WORKDIR}/selinux-${BP}/${BPN}"

RDEPENDS:${PN}:remove:class-target = "selinux-python"

# remove libcgroup which is not mandatory in the build.
EXTRA_DEPENDS_remove += "libcgroup"
