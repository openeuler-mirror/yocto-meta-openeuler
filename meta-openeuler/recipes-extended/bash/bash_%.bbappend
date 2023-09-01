# main bbfile: yocto-poky/meta/recipes-extended/bash/bash_5.1.16.bb

# bash version in openeuler
PV = "5.2.15"

# These patches have been merged in this version
SRC_URI:remove = " file://CVE-2022-3715.patch \
           file://execute_cmd.patch \
           file://use_aclocal.patch \
           file://makerace.patch \
           file://makerace2.patch \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-001;apply=yes;striplevel=0;name=patch001 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-002;apply=yes;striplevel=0;name=patch002 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-003;apply=yes;striplevel=0;name=patch003 \
           ${GNU_MIRROR}/bash/bash-${PV}-patches/bash51-004;apply=yes;striplevel=0;name=patch004 \
           "

# patches in openeuler
SRC_URI:prepend = " \
           file://bash-2.05a-interpreter.patch \
           file://bash-2.05b-pgrp_sync.patch \
           file://bash-4.0-nobits.patch \
           file://bash-4.2-coverity.patch \
           file://bash-4.3-noecho.patch \
           file://bash-4.3-memleak-lc_all.patch \
           file://bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://enable-dot-logout-and-source-bashrc-through-ssh.patch \
           file://cd-alias.patch \
"

SRC_URI[tarball.sha256sum] = "13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"

# When testing the performance of the shell using UnixBench, we found that the sh of busybox(ash)
# outperformed bash, so we still make sh link to busybox instead of bash.
ALTERNATIVE:${PN}:remove = "sh"
