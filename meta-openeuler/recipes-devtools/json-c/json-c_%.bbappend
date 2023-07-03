# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

# json-c version in openEuler
PV = "0.16-20220414"

# apply patch
SRC_URI = " \
        file://json-c-${PV}.tar.gz \
        file://backport-Add-test-to-check-for-the-memory-leak-mentioned-in-issue-781.patch \
        file://backport-Fix-memory-leak-with-emtpy-strings-in-json_object_set_string.patch \
        file://backport-json_object_from_fd_ex-fail-if-file-is-too-large.patch \
        "

SRC_URI[md5sum] = "4f3288a5f14e0e6abe914213f41234e0"
SRC_URI[sha256sum] = "3ecaeedffd99a60b1262819f9e60d7d983844073abc74e495cb822b251904185"

S = "${WORKDIR}/json-c-json-c-0.16-20220414"
