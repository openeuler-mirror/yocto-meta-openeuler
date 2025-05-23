# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

# json-c version in openEuler
PV = "0.17-20230812"

# openeuler src package
SRC_URI:remove = " \
        file://backport-fix-issue-854-Set-error-json_tokener_error_memory-in.patch \
        file://backport-Handle-yet-another-out-of-memory-condition.patch \
        file://backport-Issue-857-fix-a-few-places-where-json_tokener-should.patch \
        file://backport-Take-2-fixing-the-placement-of-json_tokener_error_memory.patch \
"

SRC_URI:prepend = " \
	file://${BP}.tar.gz \
	file://backport-fix-issue-854-Set-error-json_tokener_error_memory-in.patch \
	file://backport-Handle-yet-another-out-of-memory-condition.patch \
	file://backport-Issue-857-fix-a-few-places-where-json_tokener-should.patch \
	file://backport-Take-2-fixing-the-placement-of-json_tokener_error_memory.patch \
	file://backport-Issue-867-disallow-control-characters-in-strict-mode.patch \
	file://backport-Fix-the-expected-output-for-test_parse.patch \
	file://backport-Fix-issue-875-cast-to-unsigned-char-so-bytes-above-0.patch \
	file://backport-Fix-the-apps-json_parse-s-strict-option-so-it-actual.patch \
	file://backport-Handle-NULL-gracefully-in-json_tokener_free.patch \
	file://backport-Issue-881-don-t-allow-json_tokener_new_ex-with-a-dep.patch \
"

SRC_URI[md5sum] = "6d724389b0a08c519d9dd6e2fac7efb8"
SRC_URI[sha256sum] = "024d302a3aadcbf9f78735320a6d5aedf8b77876c8ac8bbb95081ca55054c7eb"

S = "${WORKDIR}/json-c-json-c-${PV}"
