# main bbfile: yocto-poky/meta/recipes-devtools/intltool/intltool_0.51.0.bb
OPENEULER_BRANCH = "openEuler-23.03"

PV = "0.51.0"

# conflict with intltool-perl5.26-regex-fixes.patch
SRC_URI_remove = "file://perl-522-deprecations.patch \
"

# apply openeuler patches
SRC_URI_prepend = "file://intltool-perl5.26-regex-fixes.patch \
           file://intltool-merge-Create-cache-file-atomically.patch \
           file://intltool_distcheck-fix.patch \
"
