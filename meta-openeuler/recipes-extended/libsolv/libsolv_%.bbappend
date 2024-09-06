# main bbfile: yocto-poky/meta/recipes-extended/libsolv/libsolv_0.7.22.bb

PV = "0.7.24"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = "\
        file://${PV}.tar.gz \
        file://backport-Treat-condition-both-as-positive-and-negative-literal-in-pool_add_pos_literals_complex_dep.patch \
        file://backport-Add-testcase-for-last-commit.patch \
        file://backport-choice-rules-also-do-solver_choicerulecheck-for-package-downgrades.patch \
        file://backport-Fix-a-couple-small-static-analysis-findings-for-uninitialized-structs.patch \
        file://backport-resolve-installed-remove-dead-code.patch \
        file://backport-Move-special-updaters-handling-into-its-own-function.patch \
        file://backport-Handle-installed-packages-in-three-passes.patch \
        file://backport-Fix-incomplete-headers.patch \
        file://backport-Fix-a-possible-format-overflow-in-dump_genid.patch \
"

# delete -DENABLE_RPMDB_BDB=ON, not used with new rpm version
PACKAGECONFIG[rpm] = "-DENABLE_RPMMD=ON -DENABLE_RPMDB=ON,,rpm"

# sync 0.7.24 from openembedded-core/meta/recipes-extended/libsolv/libsolv_0.7.24.bb
DEPENDS += " zstd "
EXTRA_OECMAKE += " -DENABLE_ZSTD_COMPRESSION=ON "
