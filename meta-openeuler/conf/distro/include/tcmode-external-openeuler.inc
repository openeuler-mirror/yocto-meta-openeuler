require conf/distro/include/tcmode-external.inc

# Use tuning-defined baselib to align with multilib and external toolchain
baselib = "${@d.getVar('BASE_LIB:tune-' + (d.getVar('DEFAULTTUNE') or 'INVALID')) or d.getVar('BASELIB')}"

# Ensure that the licensing variables are available to the toolchain.
export MGLS_LICENSE_FILE
export LM_LICENSE_FILE

# canon-prefix-map was introduced in gcc 13, but openEuler's external toolchain
# uses GCC 12.3 which does not support it. Remove it from DEBUG_PREFIX_MAP.
REMOVE_CANON_PREFIX_MAP = "-fcanon-prefix-map"
DEBUG_PREFIX_MAP:remove = "${REMOVE_CANON_PREFIX_MAP}"

python openeuler_metadata_setup () {
    # Ensure that changes to toolchain licensing don't affect checksums
    license_vars = ['MGLS_LICENSE_FILE', 'LM_LICENSE_FILE']
    d.appendVar('BB_BASEHASH_IGNORE_VARS', ' ' + ' '.join(license_vars))
}
openeuler_metadata_setup[eventmask] = "bb.event.ConfigParsed"
addhandler openeuler_metadata_setup
