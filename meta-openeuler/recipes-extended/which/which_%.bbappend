# bbfile: yocto-poky/meta/recipes-extended/which/which_2.21.bb

PV = "2.25"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504                     file://which.c;beginline=1;endline=17;md5=bcd173cbf5381e10d43be8d6ca6da3b5 "

SRC_URI = "file://which-${PV}.tar.gz"

# the shipped configure does not know libtool sysroot handling
CONFIGUREOPTS:remove = "--with-libtool-sysroot=${STAGING_DIR_HOST}"

# the cwm4 uid_t/gid_t probes misfire in this cross environment and
# would emit bogus "#define uid_t int" fallbacks; cache the answers
CACHED_CONFIGUREVARS += "ac_cv_type_uid_t=yes ac_cv_type_gid_t=yes"

# which 2.25 uses the cwm4 macro framework (AC_INIT lives inside an
# m4_include), so autoreconf cannot regenerate configure; run the
# configure script shipped in the release tarball instead
do_configure() {
    gnu-configize ${S}
    oe_runconf
}

# drop the bogus fallback the cwm4 uid_t probe emits in this
# cross environment (the real uid_t comes from sys/types.h)
do_configure:append() {
    sed -i '/^#define uid_t int$/d' ${B}/config.h
}

do_configure:prepend() {
    # 2.25 dropped the tilde/ subdirectory; provide an empty Makefile.am
    # so the base recipe's ACLOCAL_CWFLAGS sed still finds its target
    mkdir -p ${S}/tilde
    touch ${S}/tilde/Makefile.am
    touch ${S}/ChangeLog

    # the cwm4-wrapped uid_t/gid_t probes misfire in this cross
    # environment (the bogus "#define uid_t int" fallback then poisons
    # every later conftest, e.g. the pwd.h check); force the answers
    # directly in the shipped configure script
    sed -i 's/ac_fn_c_check_type "$LINENO" "uid_t" "ac_cv_type_uid_t" "$ac_includes_default"/ac_cv_type_uid_t=yes/' ${S}/configure
    sed -i 's/ac_fn_c_check_type "$LINENO" "gid_t" "ac_cv_type_gid_t" "$ac_includes_default"/ac_cv_type_gid_t=yes/' ${S}/configure
    sed -i 's/^AM_INIT_AUTOMAKE$/AM_INIT_AUTOMAKE([foreign])/' ${S}/configure.ac

    sed -i '/#include "bash.h"/a\
#include <limits.h>\
#ifndef PATH_MAX\
#define PATH_MAX 4096\
#endif\
' ${S}/which.c

    sed -i 's/static char home\[256\]/static char home[PATH_MAX]/' ${S}/which.c
    sed -i 's/static char cwd\[256\]/static char cwd[PATH_MAX]/' ${S}/which.c
    sed -i 's/static char result\[256\]/static char result[PATH_MAX]/' ${S}/which.c


    sed -i 's/char \*found = NULL, \*full_path;/char *found = NULL, *full_path = NULL;/' ${S}/which.c
    sed -i 's/char buf\[1024\];/char buf[1024] = {};/' ${S}/which.c
}

S = "${WORKDIR}/which-${PV}"

# no libiberty in this cross environment; which.c provides the
# xmalloc/xrealloc fallbacks behind NEED_XMALLOC (the native RPM build
# links against libiberty instead)
CFLAGS:append = " -DNEED_XMALLOC"

ASSUME_PROVIDE_PKGS = "which"
