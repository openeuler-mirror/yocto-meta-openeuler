PV = "3.3"

OPENEULER_SRC_URI_REMOVE = "https git http"

# file and patches from openEuler
SRC_URI_prepend = " \
        file://${BP}.tar.gz \
        file://backport-libsepol-add-missing-oom-checks.patch;striplevel=2 \
        file://backport-libsepol-check-correct-pointer-for-oom.patch;striplevel=2 \
        file://backport-libsepol-avoid-potential-NULL-dereference-on-optional-parameter.patch;striplevel=2 \
        file://backport-libsepol-do-not-modify-policy-during-write.patch;striplevel=2 \
        file://backport-libsepol-enclose-macro-parameters-and-replacement-lists-in-parentheses.patch;striplevel=2 \
        file://backport-libsepol-rename-validate_policydb-to-policydb_validate.patch;striplevel=2 \
        file://backport-libsepol-fix-missing-double-quotes-in-typetransition-CIL-rule.patch;striplevel=2 \
        file://backport-hashtab-update.patch;striplevel=2 \
        file://backport-libsepol-check-for-overflow-in-put_entry.patch;striplevel=2 \
        file://backport-libsepol-dump-non-mls-validatetrans-rules-as-such.patch;striplevel=2 \
        file://backport-libsepol-expand-use-identical-type-to-avoid-implicit-conversion.patch;striplevel=2 \
        file://backport-libsepol-cil-Fix-class-permission-verification-in-CIL.patch;striplevel=2 \
        file://backport-libsepol-validate-old-style-range-trans-classes.patch;striplevel=2 \
        file://backport-libsepol-validate-check-low-category-is-not-bigger-than-high.patch;striplevel=2 \
        file://backport-libsepol-Validate-conditional-expressions.patch;striplevel=2 \
        file://backport-libsepol-reject-avtab-entries-with-invalid-specifier.patch;striplevel=2 \
        file://backport-libsepol-avtab-check-read-counts-for-saturation.patch;striplevel=2 \
        file://backport-libsepol-expand-skip-invalid-cat.patch;striplevel=2 \
        file://backport-libsepol-more-strict-validation.patch;striplevel=2 \
        file://backport-libsepol-reject-unsupported-policy-capabilities.patch;striplevel=2 \
        file://backport-libsepol-adjust-type-for-saturation-check.patch;striplevel=2 \
        file://backport-libsepol-enhance-saturation-check.patch;striplevel=2 \
        file://backport-libsepol-avoid-leak-in-OOM-branch.patch;striplevel=2 \
        file://backport-libsepol-avoid-memory-corruption-on-realloc-failure.patch;striplevel=2 \
        file://backport-libsepol-cil-Do-not-allow-classpermissionset-to-use-.patch;striplevel=2 \
        file://backport-libsepol-add-check-for-category-value-before-printin.patch;striplevel=2 \
        file://backport-libsepol-use-correct-type-to-avoid-truncations.patch;striplevel=2 \
        file://backport-libsepol-reject-invalid-class-datums.patch;striplevel=2 \
        file://backport-libsepol-reject-linking-modules-with-no-avrules.patch;striplevel=2 \
        file://backport-libsepol-avoid-integer-overflow-in-add_i_to_a.patch;striplevel=2 \
        file://backport-libsepol-validate-empty-common-classes-in-scope-indi.patch;striplevel=2 \
        file://backport-libsepol-validate-expanded-user-range-and-level.patch;striplevel=2 \
        file://backport-libsepol-validate-MLS-levels.patch;striplevel=2 \
        file://backport-libsepol-validate-ocontexts.patch;striplevel=2 \
        file://backport-libsepol-validate-the-identifier-for-initials-SID-is.patch;striplevel=2 \
        file://backport-libsepol-reorder-calloc-3-arguments.patch;striplevel=2 \
        "

SRC_URI[md5sum] = "55fef291fa5fa5b43bd98e1bc1c3d088"
SRC_URI[sha256sum] = "fc277ac5b52d59d2cd81eec8b1cccd450301d8b54d9dd48a993aea0577cf0336"

S = "${WORKDIR}/${BP}"
