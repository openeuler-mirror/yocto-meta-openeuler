# Copyright OpenEmbedded Contributors
# SPDX-License-Identifier: MIT
#
# Remove the unknown suffix in runtime version for gnupg and its
# related packages: when autogen.sh runs outside of a git repo the
# find-version function assumes a beta version and appends "-unknown"
# (e.g. libgpg-error's gpg-error.pc reports "1.47-unknown", which
# breaks gnupg's minimum-version check).
do_configure:prepend() {
    if [ -f ${S}/autogen.sh ]; then
        sed -i \
            -e 's/^\([[:space:]]*\)beta=yes$/\1beta=no/' \
            -e 's/^\([[:space:]]*\)tmp="-unknown"$/\1tmp=""/' \
            ${S}/autogen.sh
    else
        bbwarn "autogen.sh not found in ${S}."
    fi
}
