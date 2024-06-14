PV = "3.3"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_prepend = "file://${BP}.tar.gz \
           file://backport-libselinux-Close-leaked-FILEs.patch \
           file://backport-libselinux-free-memory-on-selabel_open-3-failure.patch \
           file://backport-libselinux-restorecon-misc-tweaks.patch \
           file://backport-libselinux-free-memory-in-error-branch.patch \
           file://backport-libselinux-restorecon-avoid-printing-NULL-pointer.patch \
           file://backport-libselinux-limit-has-buffer-size.patch \
           file://backport-libselinux-correctly-hash-specfiles-larger-than-4G.patch \
           file://backport-libselinux-simplify-policy-path-logic-to-avoid-uninitialized-read.patch \
           file://backport-libselinux-do-not-return-the-cached-prev_current-value-when-using-getpidcon.patch \
           file://backport-libselinux-Ignore-missing-directories-when-i-is-used.patch \
           file://backport-libselinux-ignore-invalid-class-name-lookup.patch \
           file://backport-libselinux-fix-memory-leaks-on-the-audit2why-module-init.patch \
           file://backport-libselinux-bail-out-on-path-truncations.patch \
           file://backport-libselinux-filter-arguments-with-path-separators.patch \
           file://backport-libselinux-fix-some-memory-issues-in-db_init.patch \
           file://backport-libselinux-add-check-for-malloc.patch \
           file://backport-libselinux-restore-use-fixed-sized-integer-for-hash-index.patch \
           file://backport-libselinux-add-check-for-calloc-in-check_booleans.patch \
           file://backport-libselinux-utils-update-selabel_partial_match.patch \
           file://backport-libselinux-avoid-regex-serialization-truncations.patch \
           file://backport-libselinux-fix-logic-for-building-android-backend.patch \
           file://backport-libselinux-free-elements-on-read_spec_entries-failur.patch \
           file://backport-libselinux-cast-to-unsigned-char-for-character-handl.patch \
           file://backport-libselinux-introduce-strlcpy.patch \
           file://backport-libselinux-introduce-reallocarray-3.patch \
           file://backport-libselinux-use-DJB2a-string-hash-function.patch \
           file://backport-libselinux-utils-free-allocated-resources.patch \
           file://backport-libselinux-enable-usage-with-pedantic-UB-sanitizers.patch \
           file://backport-libselinux-reorder-calloc-3-arguments.patch \
           file://backport-libselinux-Fix-ordering-of-arguments-to-calloc.patch \
           file://backport-libselinux-use-reentrant-strtok_r-3.patch \
           file://do-malloc-trim-after-load-policy.patch \
           "

SRC_URI[md5sum] = "11d0be95e63fbe73a34d1645c5f17e28"
SRC_URI[sha256sum] = "77c294a927e6795c2e98f74b5c3adde9c8839690e9255b767c5fca6acff9b779"

S = "${WORKDIR}/${BP}"
