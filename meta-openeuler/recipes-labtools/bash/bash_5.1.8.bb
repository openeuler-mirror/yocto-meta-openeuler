require bash.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = "file://bash/${BP}.tar.gz \
           file://bash/bash-2.05a-interpreter.patch \
           file://bash/bash-2.05b-pgrp_sync.patch \
           file://bash/bash-4.0-nobits.patch \
           file://bash/bash-4.2-coverity.patch \
           file://bash/bash-4.3-noecho.patch \
           file://bash/bash-4.3-memleak-lc_all.patch \
           file://bash/bugfix-Forbidden-non-root-user-to-clear-history.patch \
           file://bash/enable-dot-logout-and-source-bashrc-through-ssh.patch \
"

# GPLv2+ (< 4.0), GPLv3+ (>= 4.0)
LICENSE = "GPLv3+"


BBCLASSEXTEND = "nativesdk"
