# main bbfile: yocto-poky/meta/recipes-extended/bzip2/bzip2_1.0.8.bb

# remove ptest files
SRC_URI_remove = "git://sourceware.org/git/bzip2-tests.git;name=bzip2-tests;branch=master \
"

# patches in openeuler
SRC_URI_append = " \
           file://0001-add-compile-option.patch \
           file://0002-CVE-2019-12900.patch \
"
