# main bb file: yocto-poky/meta/recipes-core/readline/readline_8.1.2.bb
#
OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "8.2"

# the patch is out of date, use openeuler patch
SRC_URI:remove = " \
        file://configure-fix.patch \
        file://norpath.patch \
        "

SRC_URI:prepend = " \
        file://readline-${PV}.tar.gz \
        file://readline-8.0-shlib.patch \
"

SRC_URI[archive.md5sum] = "44c762f4abaca8114858e44ca8ee9777"
SRC_URI[archive.sha256sum] = "a3d4637cdbd76f3cbc9566db90306a6af7bef90b291f7c9bc5fd8b0b0db9c686"

# diff from oe 8.2 bb
# see: http://cgit.openembedded.org/openembedded-core/plain/meta/recipes-core/readline/readline.inc
EXTRA_OECONF += "bash_cv_termcap_lib=ncurses --with-shared-termcap-library"

