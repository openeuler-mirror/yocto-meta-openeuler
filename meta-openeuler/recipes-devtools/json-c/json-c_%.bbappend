# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# json-c version in openEuler
PV = "0.16-20220414"

S = "${WORKDIR}/json-c-json-c-0.16-20220414"

# apply patch
SRC_URI += " \
        file://json-c-${PV}.tar.gz \
        file://backport-Add-test-to-check-for-the-memory-leak-mentioned-in-issue-781.patch \
        file://backport-Fix-memory-leak-with-emtpy-strings-in-json_object_set_string.patch \
        file://backport-json_object_from_fd_ex-fail-if-file-is-too-large.patch \
        file://backport-Explicitly-check-for-integer-overflow-when-parsing.patch \
        file://backport-Fix-build-with-clang-15.patch \
        file://backport-json_tokener_parse_ex-handle-out-of-memory-errors.patch \
        "
