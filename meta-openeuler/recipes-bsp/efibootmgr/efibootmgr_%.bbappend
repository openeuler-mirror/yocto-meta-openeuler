# ref: https://git.openembedded.org/openembedded-core/tree/meta/recipes-bsp/efibootmgr/efibootmgr_18.bb
PV = "18"

S = "${WORKDIR}/efibootmgr-${PV}"

SRC_URI:prepend = " \
    file://${PV}.tar.gz \
    file://backport-Update-efibootmgr.c.patch \
    file://backport-Add-missing-short-option-handling-for-index-I.patch \
    file://backport-Fix-segfault-when-passed-index-is-greater-than-curre.patch \
    file://backport-Fix-the-incorrect-long-parameter-in-help-messages.patch \
    file://backport-efibootmgr-delete_bootnext-is-just-a-boolean-not-an-entry-id.patch \
"

