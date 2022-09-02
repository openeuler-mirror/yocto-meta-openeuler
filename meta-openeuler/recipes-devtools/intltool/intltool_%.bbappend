# main bbfile: yocto-poky/meta/recipes-devtools/intltool/intltool_0.51.0.bb

PV = "0.51.0"

# remove tar.gz files and code patches from poky
SRC_URI_remove = " \
        http://launchpad.net/${BPN}/trunk/${PV}/+download/${BP}.tar.gz \
"

# append files and patches from openeuler
# failed patches of openeuler: intltool-perl5.26-regex-fixes.patch
SRC_URI_append = " \
    file://intltool-${PV}.tar.gz \
    file://intltool-merge-Create-cache-file-atomically.patch \
    file://intltool_distcheck-fix.patch \
"
