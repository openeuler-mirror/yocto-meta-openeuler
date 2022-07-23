# main bb file: yocto-poky/meta/recipes-devtools/flex/flex_2.6.4.bb

# apply patches in openEuler
SRC_URI_prepend = "file://build-AC_USE_SYSTEM_EXTENSIONS-in-configure.ac.patch \
           file://filter-memory-leak-free-scanner-postprocessing.patch \
           file://scanner-c-i-j-should-preserve-case.patch \
           file://filter-Output-correct-line-value-for-current-file.patch \
           file://scanner-memory-leak-free-scanner-generator.patch \
           file://scanner-Ignore-comment-lines-in-skeleton-files.patch \
           file://scanner-temporarily-protect-against-ccl-overflow-ove.patch \
           file://scanner-prevent-overflow-in-add_action.patch \
"

# remove this patch as it already exists in openEuler
SRC_URI_remove = "file://0001-build-AC_USE_SYSTEM_EXTENSIONS-in-configure.ac.patch \
"