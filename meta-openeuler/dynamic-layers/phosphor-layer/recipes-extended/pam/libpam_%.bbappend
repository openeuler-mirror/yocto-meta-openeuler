# these plugins are not generated in libpam
RDEPENDS:${PN}-runtime:remove = " \
    ${MLPREFIX}pam-plugin-cracklib-${libpam_suffix} \
    ${MLPREFIX}pam-plugin-tally2-${libpam_suffix} \
"