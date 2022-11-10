# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

# json-c version in openEuler
PV = "0.16-20220414"

# apply patch
SRC_URI += "\
"

SRC_URI[md5sum] = "4f3288a5f14e0e6abe914213f41234e0"
SRC_URI[sha256sum] = "3ecaeedffd99a60b1262819f9e60d7d983844073abc74e495cb822b251904185"

S = "${WORKDIR}/json-c-json-c-0.16-20220414"
