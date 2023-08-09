# main bb file: yocto-poky/meta/recipes-devtools/flex/flex_2.6.4.bb

# apply patches in openEuler
# 0001-build-AC_USE_SYSTEM_EXTENSIONS-in-configure.ac.patch exists in poky
#
# m4:stdin:2816: ERROR: end of file in string
# mkskel.sh-fix-EOL-issue-for-CRLF-systems.patch 
# 0001-scanner-fix-default-of-yy_top_state.patch
# 0002-scanner-fix-default-of-yy_top_state.patch
SRC_URI:prepend = "file://filter-memory-leak-free-scanner-postprocessing.patch \
           file://scanner-c-i-j-should-preserve-case.patch \
           file://filter-Output-correct-line-value-for-current-file.patch \
           file://scanner-memory-leak-free-scanner-generator.patch \
           file://scanner-Ignore-comment-lines-in-skeleton-files.patch \
           file://scanner-temporarily-protect-against-ccl-overflow-ove.patch \
           file://scanner-prevent-overflow-in-add_action.patch \
           "
