# bbfile: yocto-poky/meta/recipes-extended/which/which_2.21.bb

SRC_URI = "file://which-${PV}.tar.gz"

do_configure:prepend() {
    touch ${S}/ChangeLog
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

    sed -i 's/int result_size, result_index/int result_size = 0, result_index = 0/' ${S}/tilde/tilde.c
    sed -i '/result_index = result_size = 0;/d' ${S}/tilde/tilde.c
    sed -i "s/if (result = strchr (string, '\~'))/result = strchr(string, '\~');\n  if (result)/" ${S}/tilde/tilde.c
    sed -i 's/ret = (char \*)xmalloc (strlen (fname));/ret = (char *)xmalloc (strlen (fname) + 1);/' ${S}/tilde/tilde.c

    sed -i 's/char \*found = NULL, \*full_path;/char *found = NULL, *full_path = NULL;/' ${S}/which.c
    sed -i 's/int status, name_len;/int status, name_len;\n  char *p;/' ${S}/which.c
    sed -i '/absolute_path_given = 0;/{N;/char \*p;/d}' ${S}/which.c
    sed -i '/name_len = strlen(name);/{n;/^$/d}' ${S}/which.c
    sed -i 's/free(full_path);/free(full_path);\n  name = NULL; p = NULL; path_list = NULL;/' ${S}/which.c
    sed -i 's/char buf\[1024\];/char buf[1024] = {};/' ${S}/which.c
}

S = "${WORKDIR}/which-${PV}"

ASSUME_PROVIDE_PKGS = "which"
