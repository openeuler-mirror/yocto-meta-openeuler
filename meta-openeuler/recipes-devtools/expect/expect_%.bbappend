# the main bb file: yocto-poky/meta/recipes-devtools/expect/expect_5.45.4.bb
OPENEULER_SRC_URI_REMOVE = "https http"

# expect-5.43.0-pkgpath.patch: build error, delete it from openeuler
SRC_URI:prepend = "file://expect${PV}.tar.gz \
           file://expect-5.43.0-log_file.patch \
           file://expect-5.45-man-page.patch \
           file://expect-5.45-match-gt-numchars-segfault.patch \
           file://expect-5.45-re-memleak.patch \
           file://expect-5.45-exp-log-buf-overflow.patch \
           file://expect-5.45-segfault-with-stubs.patch \
           file://expect-5.45-fd-leak.patch \
           file://expect-5.32.2-random.patch \
           file://expect-5.45-mkpasswd-dash.patch \
           file://expect-5.45-passmass-su-full-path.patch \
           file://expect-5.45-mkpasswd-man.patch \
           file://expect-5.45-format-security.patch \
           "

# expect-5.45-format-security.patch and 0001-Resolve-string-formatting-issues.patch provide the same
# 0001-expect-Fix-segfaults-if-Tcl-is-built-with-stubs-and-.patch conflict with expect-5.45-segfault-with-stubs.patch
SRC_URI:remove = "file://0001-Resolve-string-formatting-issues.patch \
           file://0001-expect-Fix-segfaults-if-Tcl-is-built-with-stubs-and-.patch \
"

# we don't need .c file pack in rootfs
FILES:${PN}-dev:append = " \
        ${libdir}/expect${PV}/*.c \
        "
