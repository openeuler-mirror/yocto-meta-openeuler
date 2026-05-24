# Blacklist recipe names which include variable references, handling
# multilibs.
#
# Ex.
#     SKIP_RECIPE_DYNAMIC += "${MLPREFIX}gcc-cross-${TARGET_ARCH}"
#     SKIP_RECIPE_DYNAMIC += "gcc-source-${@'${GCCVERSION}'.replace('%', '')}"

SKIP_RECIPE_DYNAMIC ?= ""

python pnblacklist_dynamic_setup () {
    d = e.data

    blacklisted = d.getVar('SKIP_RECIPE_DYNAMIC', False)
    if not blacklisted.strip():
        return

    multilibs = d.getVar('MULTILIBS', True) or ''

    # this block has been copied from base.bbclass so keep it in sync
    prefixes = []
    for ext in multilibs.split():
        eext = ext.split(':')
        if len(eext) > 1 and eext[0] == 'multilib':
            prefixes.append(eext[1])

    to_blacklist = set()
    for prefix in [''] + prefixes:
        localdata = bb.data.createCopy(d)
        if prefix:
            localdata.setVar('MLPREFIX', prefix + '-')
            override = ':virtclass-multilib-' + prefix
            localdata.setVar('OVERRIDES', localdata.getVar('OVERRIDES', False) + override)
            bb.data.update_data(localdata)

        to_blacklist |= set(filter(None, localdata.getVar('SKIP_RECIPE_DYNAMIC').split()))

    for blrecipe in to_blacklist:
        d.setVarFlag('SKIP_RECIPE', blrecipe, 'blacklisted by SKIP_RECIPE_DYNAMIC')
}
pnblacklist_dynamic_setup[eventmask] = "bb.event.ConfigParsed"
addhandler pnblacklist_dynamic_setup
