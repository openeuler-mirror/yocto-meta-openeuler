FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "4.35"

# conflict : nspr-gcc-atomics.patch 
SRC_URI:prepend = " \
    file://nspr-${PV}.tar.gz \
"

# patches from 4.35
SRC_URI:append = " \
    file://0001-config-nspr-config.in-don-t-pass-LDFLAGS.patch \
    file://0001-Fix-Wincompatible-function-pointer-types.patch \
"

# 4.35 no need
SRC_URI:remove = " \
    file://remove-srcdir-from-configure-in.patch \
"

# sync 4.35 config
CACHED_CONFIGUREVARS:append:libc-musl = " CFLAGS='${CFLAGS} -D_PR_POLL_AVAILABLE \
                                          -D_PR_HAVE_LARGE_OFF_T -D_PR_INET6 -D_PR_HAVE_INET_NTOP \
                                          -D_PR_HAVE_GETHOSTBYNAME2 -D_PR_HAVE_GETADDRINFO \
                                          -D_PR_INET6_PROBE -DNO_DLOPEN_NULL'"

