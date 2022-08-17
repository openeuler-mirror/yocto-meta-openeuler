PV = "3.7"

# sync openeuler's grep to use pcre2
PACKAGECONFIG_append += "pcre2"
PACKAGECONFIG_remove += "pcre"
PACKAGECONFIG[pcre2] = "--enable-perl-regexp,--disable-perl-regexp,libpcre2"

SRC_URI += " \
    file://backport-grep-avoid-sticky-problem-with-f-f.patch \
    file://backport-grep-s-does-not-suppress-binary-file-matches.patch \
    file://backport-grep-work-around-PCRE-bug.patch \
    file://backport-grep-migrate-to-pcre2.patch \
    file://backport-grep-Don-t-limit-jitstack_max-to-INT_MAX.patch \
    file://backport-grep-speed-up-fix-bad-UTF8-check-with-P.patch \
    file://backport-grep-fix-minor-P-memory-leak.patch \
"

SRC_URI[sha256sum] = "5c10da312460aec721984d5d83246d24520ec438dd48d7ab5a05dbc0d6d6823c"
