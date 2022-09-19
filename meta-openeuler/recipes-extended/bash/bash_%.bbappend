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
           file://bash/bash-2.05a-interpreter.patch \
           file://bash/bash-2.05b-pgrp_sync.patch \
           file://bash/bash-4.0-nobits.patch \
           file://bash/bash-4.2-coverity.patch \
           file://bash/bash-4.3-noecho.patch \
           file://bash/bash-4.3-memleak-lc_all.patch \
           file://bash/bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://bash/enable-dot-logout-and-source-bashrc-through-ssh.patch \
           file://bash/cd-alias.patch \
"

SRC_URI[tarball.sha256sum] = "0cfb5c9bb1a29f800a97bd242d19511c997a1013815b805e0fdd32214113d6be"

# When testing the performance of the shell using UnixBench, we found that the sh of busybox(ash)
# outperformed bash, so we still make sh link to busybox instead of bash.
ALTERNATIVE_${PN}_remove += "sh"
