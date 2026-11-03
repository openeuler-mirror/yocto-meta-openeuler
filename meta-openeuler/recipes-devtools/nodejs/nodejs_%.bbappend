# main bb: meta-openembedded/meta-oe/recipes-devtools/nodejs/nodejs_24.18.1.bb
# (kept in-tree in meta-openeuler, based on the same meta-oe recipe;
#  0002-Revert-deps-V8-tagged.patch and 0003-fix-fd-is-null-when-calling-
#  clearBuffer.patch from the src repo were dropped upstream and are no
#  longer shipped there)

# apply source package in openEuler
SRC_URI:prepend = " \
    file://node-v${PV}.tar.xz \
"

# the src-openeuler spec builds against the bundled c-ares; the system
# c-ares in this layer (1.19.1) is too old for node 24 (needs >= 1.27
# for the ares_dns_* API), so use the bundled one as well
PACKAGECONFIG:remove = "ares"
