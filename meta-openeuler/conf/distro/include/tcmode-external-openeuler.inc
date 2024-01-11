require conf/distro/include/tcmode-external.inc

# Use tuning-defined baselib to align with multilib and external toolchain
baselib = "${@d.getVar('BASE_LIB:tune-' + (d.getVar('DEFAULTTUNE') or 'INVALID')) or d.getVar('BASELIB')}"

# Ensure that the licensing variables are available to the toolchain.
export MGLS_LICENSE_FILE
export LM_LICENSE_FILE

def openeuler_version(d):
    version_output = external_run(d, d.getVar('EXTERNAL_CC') or 'gcc', '-v')

    try:
        version = version_output.splitlines()[-1]
    except IndexError:
        bb.error('Unexpected output for {}: {}'.format(d.getVar('EXTERNAL_TOOLCHAIN_BIN') + '/' + (d.getVar('EXTERNAL_CC') or 'gcc') + ' -v', version_output))
        version = 'UNKNOWN'

    if version != 'UNKNOWN':
        # gcc version xx.yy.zz nnnnnnn, here we get xx.yy.zz
        main_version = version.split()[2]
        if main_version == 'Preview':
            main_version = version.split()[-3]
        elif '(GCC' in main_version or '(gcc' in main_version:
            match = re.search("(gcc", main_version, re.IGNORECASE)
            bb.warn(match.group())
            return match.group()
        else:
            return main_version
    return 'UNKNOWN'

OPENEULER_VERSION = "${@openeuler_version(d)}"
OPENEULER_VERSION:allarch = ""
OPENEULER_VERSION[vardepvalue] = "${OPENEULER_VERSION}"

# Add openeuler toolchain version to external recipe versions
EXTERNAL_PV_SUFFIX ?= "${@'-${OPENEULER_VERSION}' if d.getVar('OPENEULER_VERSION') != 'UNKNOWN' else ''}"
EXTERNAL_PV_SUFFIX[vardepvalue] = "${EXTERNAL_PV_SUFFIX}"
EXTERNAL_PV_SUFFIX:allarch = ""

# Make it clear that this version is the toolchain, not the CodeBench IDE
OPENEULER_TOOLCHAIN_VERSION = "${OPENEULER_VERSION}"

BUILDCFG_VARS += "${@'OPENEULER_TOOLCHAIN_VERSION' if d.getVar('OPENEULER_VERSION') != 'UNKNOWN' else ''}"

python openeuler_metadata_setup () {
    # Ensure that changes to toolchain licensing don't affect checksums
    license_vars = ['MGLS_LICENSE_FILE', 'LM_LICENSE_FILE']
    d.appendVar('BB_BASEHASH_IGNORE_VARS', ' ' + ' '.join(license_vars))
}
openeuler_metadata_setup[eventmask] = "bb.event.ConfigParsed"
addhandler openeuler_metadata_setup
