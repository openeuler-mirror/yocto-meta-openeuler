# main bbfile: yocto-poky/meta/recipes-extended/bash/bash_5.1.16.bb

# bash version in openeuler
PV = "5.2.15"

# These patches have been merged in this version
SRC_URI:remove = " file://CVE-2022-3715.patch \
           file://execute_cmd.patch \
           file://use_aclocal.patch \
           file://makerace.patch \
           file://makerace2.patch \
           "

# patches in openeuler
SRC_URI:prepend = " \
           file://${BP}.tar.gz;name=tarball \
           file://bash-2.05a-interpreter.patch \
           file://bash-2.05b-pgrp_sync.patch \
           file://bash-4.0-nobits.patch \
           file://bash-4.2-coverity.patch \
           file://bash-4.3-noecho.patch \
           file://bash-4.3-memleak-lc_all.patch \
           file://bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://enable-dot-logout-and-source-bashrc-through-ssh.patch \
           file://cd-alias.patch \
           file://bash-5.1-sw.patch \
           file://backport-fix-for-nofork-comsub-command-printing-fix-for-crash.patch \
           file://backport-fix-small-memleak-in-globbing.patch \
           file://backport-fix-for-leak-when-completing-command-word-with-glob-.patch \
"

SRC_URI[tarball.sha256sum] = "13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"

# When testing the performance of the shell using UnixBench, we found that the sh of busybox(ash)
# outperformed bash, so we still make sh link to busybox instead of bash.
ALTERNATIVE:${PN}:remove = "sh"
