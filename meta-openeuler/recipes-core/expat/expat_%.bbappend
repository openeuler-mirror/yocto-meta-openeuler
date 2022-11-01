PV = "2.4.1"

SRC_URI[sha256sum] = "a00ae8a6b96b63a3910ddc1100b1a7ef50dc26dceb65ced18ded31ab392f132b"

# patches from openeuler
SRC_URI = " \
    ${SOURCEFORGE_MIRROR}/expat/expat-${PV}.tar.gz \
    file://backport-CVE-2021-45960.patch \
    file://backport-CVE-2021-46143.patch \
    file://backport-CVE-2022-22822-CVE-2022-22823-CVE-2022-22824-CVE-2022-22825-CVE-2022-22826-CVE-2022-22827.patch \
    file://backport-CVE-2022-23852-lib-Detect-and-prevent-integer-overflow-in-XML_GetBu.patch \
    file://backport-CVE-2022-23852-tests-Cover-integer-overflow-in-XML_GetBuffer-CVE-20.patch \
    file://backport-CVE-2022-23990-lib-Prevent-integer-overflow-in-doProlog-CVE-2022-23.patch \
    file://backport-CVE-2022-25235-lib-Add-missing-validation-of-encoding.patch \
    file://backport-tests-Cover-missing-validation-of-encoding.patch \
    file://backport-CVE-2022-25236-lib-Protect-against-malicious-namespace-declarations.patch \
    file://backport-tests-Cover-CVE-2022-25236.patch \
    file://backport-CVE-2022-25313-Prevent-stack-exhaustion-in-build_model.patch \
    file://backport-CVE-2022-25314-Prevent-integer-overflow-in-copyString.patch \
    file://backport-CVE-2022-25315-Prevent-integer-overflow-in-storeRawNames.patch \
    file://backport-Fix-build_model-regression.patch \
    file://backport-tests-Protect-against-nested-element-declaration-mod.patch \
    file://backport-lib-Fix-harmless-use-of-uninitialized-memory.patch \
    file://backport-lib-Drop-unused-macro-UTF8_GET_NAMING.patch \
    file://backport-lib-Relax-fix-to-CVE-2022-25236-with-regard-to-RFC-3.patch \
    file://backport-tests-Cover-relaxed-fix-to-CVE-2022-25236.patch \
    file://backport-0001-CVE-2022-40674.patch \
    file://backport-0002-CVE-2022-40674.patch \
    file://backport-CVE-2022-43680.patch \
    file://backport-tests-Cover-overeager-DTD-destruction-in-XML_Externa.patch \
"

# patch from poky
SRC_URI += " \
           file://libtool-tag.patch \
"
