# main bb: meta-openembedded/meta-oe/recipes-devtools/nodejs/nodejs_20.11.1.bb

PV = "20.11.1"

# 0001-Use-system-uv-zlib.patch from openeuler is the same as 
# 0001-Disable-running-gyp-files-for-bundled-deps.patch from openembedded
SRC_URI:prepend = " \
    file://node-v${PV}.tar.xz \
    file://0002-Revert-deps-V8-tagged.patch \
"

