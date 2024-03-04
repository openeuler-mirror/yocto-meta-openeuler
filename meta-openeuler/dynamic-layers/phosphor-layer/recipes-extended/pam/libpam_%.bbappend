# these plugins are not generated in libpam
RDEPENDS:${PN}-runtime:remove = " \
    ${MLPREFIX}pam-plugin-cracklib-${libpam_suffix} \
    ${MLPREFIX}pam-plugin-tally2-${libpam_suffix} \
"

# use poky's pam configuration, since openEuler use it.
# Do not use the OpenBMC's pam configuration, since we remove
# the pam-plugin-cracklib and pam-plugin-tally2, which causes error.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
