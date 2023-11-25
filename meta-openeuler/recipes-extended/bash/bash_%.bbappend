# main bbfile: yocto-poky/meta/recipes-extended/bash/bash_5.1.bb

# bash version in openeuler
PV = "5.1.8"

# These patches have been merged in this version
SRC_URI_remove += " \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-001;apply=yes;striplevel=0;name=patch001 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-002;apply=yes;striplevel=0;name=patch002 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-003;apply=yes;striplevel=0;name=patch003 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-004;apply=yes;striplevel=0;name=patch004 \
           "

# patches in openeuler
SRC_URI_append += " \
           file://bash-2.05a-interpreter.patch \
           file://bash-2.05b-pgrp_sync.patch \
           file://bash-4.0-nobits.patch \
           file://bash-4.2-coverity.patch \
           file://bash-4.3-noecho.patch \
           file://bash-4.3-memleak-lc_all.patch \
           file://bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://enable-dot-logout-and-source-bashrc-through-ssh.patch \
           file://cd-alias.patch \
           file://backport-fix-crash-in-readline-when-started-with-an-invalid.patch \
           file://backport-Bash-5.1-patch-10-fix-for-wait-n-being-interrupted-b.patch \
           file://backport-Bash-5.1-patch-11-save-and-restore-alias-parsing-whe.patch \ 
           file://backport-Bash-5.1-patch-12-fix-race-condition-with-child-proc.patch \
           file://backport-Bash-5.1-patch-13-fix-tilde-expansion-after-unquoted.patch \
           file://backport-Bash-5.1-patch-14-fix-off-by-one-error-when-reading-.patch \
           file://backport-Bash-5.1-patch-15-fix-readline-display-of-some-chara.patch \
           file://backport-Bash-5.1-patch-16-fix-interpretation-of-multiple-ins.patch \
           file://backport-changes-to-documentation-to-reduce-gender-specific-l.patch \
           file://backport-fixes-for-array-subscripts-and-values-containing-0x0.patch \
           file://backport-fix-for-nofork-comsub-command-printing-fix-for-crash.patch \
           file://backport-fix-small-memleak-in-globbing.patch \
           file://backport-fix-for-leak-when-completing-command-word-with-glob-.patch \
"

SRC_URI[tarball.sha256sum] = "0cfb5c9bb1a29f800a97bd242d19511c997a1013815b805e0fdd32214113d6be"

# When testing the performance of the shell using UnixBench, we found that the sh of busybox(ash)
# outperformed bash, so we still make sh link to busybox instead of bash.
ALTERNATIVE_${PN}_remove += "sh"
