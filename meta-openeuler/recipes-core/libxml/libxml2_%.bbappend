# version in openEuler
PV = "2.9.14"

# remove patches can't apply
# fix-execution-of-ptests.patch, patch-fuzz warning
SRC_URI_remove = "http://www.xmlsoft.org/sources/libxml2-${PV}.tar.gz;name=libtar \
            http://www.w3.org/XML/Test/xmlts20080827.tar.gz;subdir=${BP};name=testtar \
            file://libxml-m4-use-pkgconfig.patch \
            file://0001-Make-ptest-run-the-python-tests-if-python-is-enabled.patch \
            file://fix-execution-of-ptests.patch \
            file://CVE-2020-7595.patch \
            file://CVE-2019-20388.patch \
            file://CVE-2020-24977.patch \
            file://fix-python39.patch \
            file://CVE-2021-3517.patch \
            file://CVE-2021-3516.patch \
            file://CVE-2021-3518-0001.patch \
            file://CVE-2021-3518-0002.patch \
            file://CVE-2021-3537.patch \
            file://CVE-2021-3541.patch \
            file://CVE-2022-23308.patch \
            file://CVE-2022-23308-fix-regression.patch \
"

# apply openEuler source package
SRC_URI_prepend = "file://${BP}.tar.xz \
"

# add patches in openEuler
SRC_URI += " \
        file://libxml2-multilib.patch \
        file://Fix-memleaks-in-xmlXIncludeProcessFlags.patch \
        file://Fix-memory-leaks-for-xmlACatalogAdd.patch \
        file://Fix-memory-leaks-in-xmlACatalogAdd-when-xmlHashAddEntry-failed.patch \
        file://backport-CVE-2022-40303-Fix-integer-overflows-with-XML_PARSE_.patch \
        file://backport-CVE-2022-40304-Fix-dict-corruption-caused-by-entity-.patch \
        file://backport-schemas-Fix-null-pointer-deref-in-xmlSchemaCheckCOSS.patch \
        file://backport-parser-Fix-potential-memory-leak-in-xmlParseAttValue.patch \
        file://backport-Add-whitespace-folding-for-some-atomic-data-types-th.patch \
        file://backport-Properly-fold-whitespace-around-the-QName-value-when.patch \
        file://backport-Avoid-arithmetic-on-freed-pointers.patch \
        file://backport-fix-xmlXPathParserContext-could-be-double-delete-in-.patch \
        file://backport-Use-UPDATE_COMPAT-consistently-in-buf.c.patch \
        file://backport-Restore-behavior-of-htmlDocContentDumpFormatOutput.patch \
        file://backport-Fix-use-after-free-bugs-when-calling-xmlTextReaderCl.patch \
        file://backport-Use-xmlNewDocText-in-xmlXIncludeCopyRange.patch \
        file://backport-xmlBufAvail-should-return-length-without-including-a.patch \
        file://backport-Fix-integer-overflow-in-xmlBufferDump.patch \
        file://backport-Fix-missing-NUL-terminators-in-xmlBuf-and-xmlBuffer-.patch \
        file://backport-Reserve-byte-for-NUL-terminator-and-report-errors-co.patch \
        file://backport-Fix-unintended-fall-through-in-xmlNodeAddContentLen.patch \
        file://backport-Don-t-reset-nsDef-when-changing-node-content.patch \
        file://backport-Avoid-double-free-if-malloc-fails-in-inputPush.patch \
        file://backport-Fix-memory-leak-in-xmlLoadEntityContent-error-path.patch \
        file://backport-Reset-nsNr-in-xmlCtxtReset.patch \
        file://backport-Fix-htmlReadMemory-mixing-up-XML-and-HTML-functions.patch \
        file://backport-Don-t-initialize-SAX-handler-in-htmlReadMemory.patch \
        file://backport-Fix-HTML-parser-with-threads-and-without-legacy.patch \
        file://backport-Fix-xmlCtxtReadDoc-with-encoding.patch \
        file://backport-Use-xmlStrlen-in-CtxtReadDoc.patch \
        file://backport-Create-stream-with-buffer-in-xmlNewStringInputStream.patch \
        file://backport-Use-xmlStrlen-in-xmlNewStringInputStream.patch \
        file://backport-Fix-memory-leak-with-invalid-XSD.patch \
        file://backport-Make-XPath-depth-check-work-with-recursive-invocatio.patch \
        file://backport-Fix-overflow-check-in-SAX2.c.patch \
        file://backport-xinclude-Fix-memory-leak-when-fuzzing.patch \
        file://backport-xinclude-Fix-more-memory-leaks-in-xmlXIncludeLoadDoc.patch \
        file://backport-schemas-Fix-infinite-loop-in-xmlSchemaCheckElemSubst.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlCreatePushParserCt.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlStaticCopyNodeList.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlNewPropInternal.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlNewDocNodeEatName.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-xmlSkipBlankChars.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSAX2ExternalSubset.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlParseReference.patch \
        file://backport-malloc-fail-Fix-use-after-free-in-xmlXIncludeAddNode.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlStringGetNodeList.patch \
        file://backport-parser-Fix-error-message-in-xmlParseCommentComplex.patch \
        file://backport-io-Fix-buffer-full-error-with-certain-buffer-sizes.patch \
        file://backport-reader-Switch-to-xmlParserInputBufferCreateMem.patch \
        file://backport-uri-Allow-port-without-host.patch \
        file://backport-parser-Fix-consumed-accounting-when-switching-encodi.patch \
        file://backport-html-Fix-check-for-end-of-comment-in-push-parser.patch \
        file://backport-parser-Fix-push-parser-with-1-3-byte-initial-chunk.patch \
        file://backport-parser-Restore-parser-state-in-xmlParseCDSect.patch \
        file://backport-parser-Remove-dangerous-check-in-xmlParseCharData.patch \
        file://backport-parser-Don-t-call-DefaultSAXHandlerInit-from-xmlInit.patch \
        file://backport-Correctly-relocate-internal-pointers-after-realloc.patch \
        file://backport-Avoid-creating-an-out-of-bounds-pointer-by-rewriting.patch \
        file://backport-error-Make-sure-that-error-messages-are-valid-UTF-8.patch \
        file://backport-io-Check-for-memory-buffer-early-in-xmlParserInputGrow.patch \
        file://backport-io-Remove-xmlInputReadCallbackNop.patch \
        file://backport-Revert-uri-Allow-port-without-host.patch \
        file://backport-xmlParseStartTag2-contains-typo-when-checking-for-default.patch \
        file://backport-parser-Fix-integer-overflow-of-input-ID.patch \
        file://backport-parser-Don-t-increase-depth-twice-when-parsing-internal.patch \
        file://backport-xpath-number-should-return-NaN.patch \
        file://backport-error-Don-t-move-past-current-position.patch \
        file://backport-malloc-fail-Handle-memory-errors-in-xmlTextReaderEntPush.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-xmlParseTextDecl.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlAddDefAttrs.patch \
        file://backport-malloc-fail-Fix-null-deref-if-growing-input-buffer-fails.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlSAX2AttributeInternal.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlBufResize.patch \
        file://backport-buf-Fix-return-value-of-xmlBufGetInputBase.patch \
        file://backport-malloc-fail-Don-t-call-xmlErrMemory-in-xmlstring.c.patch \
        file://backport-malloc-fail-Fix-reallocation-in-inputPush.patch \
        file://backport-malloc-fail-Fix-use-after-free-in-xmlParseStartTag2.patch \
        file://backport-malloc-fail-Add-error-checks-in-xmlXPathEqualValuesCommon.patch \
        file://backport-malloc-fail-Add-error-check-in-xmlXPathEqualNodeSetFloat.patch \
        file://backport-malloc-fail-Fix-error-check-in-xmlXPathCompareValues.patch \
        file://backport-malloc-fail-Record-malloc-failure-in-xmlXPathCompLiteral.patch \
        file://backport-malloc-fail-Check-return-value-of-xmlXPathNodeSetDupNs.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlXIncludeLoadTxt.patch \
        file://backport-malloc-fail-Fix-reallocation-in-xmlXIncludeNewRef.patch \
        file://backport-xinclude-Fix-quadratic-behavior-in-xmlXIncludeLoadTx.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlParserInputBufferCreateMem.patch \
        file://backport-malloc-fail-Check-for-malloc-failure-in-xmlFindCharEncodingHandler.patch \
        file://backport-malloc-fail-Fix-leak-of-xmlCharEncodingHandler.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlParseEntityDecl.patch \
        file://backport-encoding-Cast-toupper-argument-to-unsigned-char.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathCompareValues.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathTryStreamCompile.patch \
        file://backport-malloc-fail-Fix-memory-leak-after-calling-valuePush.patch \
        file://backport-malloc-fail-Fix-memory-leak-after-calling-xmlXPathWrapNodeSet.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXIncludeAddNode.patch \
        file://backport-malloc-fail-Fix-memory-leak-after-xmlRegNewState.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSAX2StartElementNs.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlGetDtdElementDesc2.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlDocDumpFormatMemoryEnc.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-htmlParseStartTag1.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXIncludeLoadTxt.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlCopyPropList.patch \
        file://backport-malloc-fail-Fix-memory-leak-after-calling-xmlXPathNodeSetMerge.patch \
        file://backport-malloc-fail-Fix-memory-leak-after-calling-xmlXPathWrapString.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathEqualValuesCommon.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-htmlCreateMemoryParserCtxt.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-htmlCreatePushParserCtxt.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-htmlParseContentInternal.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-htmlParseStartTag2.patch \
        file://backport-malloc-fail-Fix-null-deref-in-htmlnamePush.patch \
        file://backport-malloc-fail-Fix-infinite-loop-in-htmlParseDocTypeDecl.patch \
        file://backport-malloc-fail-Fix-error-code-in-htmlParseChunk.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlFAParseCharProp.patch \
        file://backport-malloc-fail-Fix-leak-of-xmlRegAtom.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlRegexpCompile.patch \
        file://backport-malloc-fail-Fix-OOB-read-after-xmlRegGetCounter.patch \
        file://backport-parser-Fix-OOB-read-when-formatting-error-message.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathEqualNodeSetF.patch \
        file://backport-malloc-fail-Fix-use-after-free-related-to-xmlXPathNo.patch \
        file://backport-regexp-Add-sanity-check-in-xmlRegCalloc2.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlXPathCompiledEvalIn.patch \
        file://backport-malloc-fail-Fix-null-deref-after-xmlPointerListAddSi.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlGetNsList.patch \
        file://backport-malloc-fail-Check-for-malloc-failure-in-xmlHashAddEn.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathCacheNewNodeS.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathDistinctSorte.patch \
        file://backport-xpath-Fix-harmless-integer-overflow-in-xmlXPathTrans.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathNameFunction.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSchemaItemListAddS.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlGet-Min-Max-Occurs.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlSchemaValAtomicType.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlSchemaInitTypes.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSchemaParse.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlCopyNamespaceList.patch \
        file://backport-malloc-fail-Fix-another-memory-leak-in-xmlSchemaBuck.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlSchemaParseUnion.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-WXS_ADD_-LOCAL-GLOBAL.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSchemaBucketCreate.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlSchemaParseWildcard.patch \
        file://backport-malloc-fail-Fix-type-confusion-after-xmlSchemaFixupT.patch \
        file://backport-malloc-fail-Fix-null-deref-after-xmlSchemaItemList-A.patch \
        file://backport-malloc-fail-Fix-null-deref-after-xmlSchemaCompareDat.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlSchemaParseUnion.patch \
        file://backport-malloc-fail-Fix-memory-leak-in-xmlXPathRegisterNs.patch \
        file://backport-catalog-Fix-memory-leaks.patch \
        file://backport-CVE-2023-29469.patch \
        file://backport-CVE-2023-28484.patch \
        file://backport-valid-Allow-xmlFreeValidCtxt-NULL.patch \
        file://backport-parser-Use-size_t-when-subtracting-input-buffer-poin.patch \
        file://backport-malloc-fail-Fix-null-deref-in-xmlParserInputShrink.patch \
        file://backport-xmllint-Fix-memory-leak-with-pattern-stream.patch \
        file://backport-xzlib-Fix-implicit-sign-change-in-xz_open.patch \
        file://backport-html-Fix-quadratic-behavior-in-htmlParseTryOrFinish.patch \
        file://backport-valid-Make-xmlValidateElement-non-recursive.patch \
        file://backport-malloc-fail-Fix-buffer-overread-in-htmlParseScript.patch \
        file://backport-malloc-fail-Add-more-error-checks-when-parsing-names.patch \
        file://backport-malloc-fail-Add-error-check-in-htmlParseHTMLAttribut.patch \
        file://backport-parser-Limit-name-length-in-xmlParseEncName.patch \
        file://backport-encoding-Fix-error-code-in-asciiToUTF8.patch \
        file://backport-malloc-fail-Fix-buffer-overread-with-HTML-doctype-de.patch \
        file://backport-parser-Fix-regression-in-xmlParserNodeInfo-accountin.patch \
        file://backport-regexp-Fix-cycle-check-in-xmlFAReduceEpsilonTransiti.patch \
        file://backport-regexp-Fix-checks-for-eliminated-transitions.patch \
        file://backport-regexp-Fix-determinism-checks.patch \
        file://backport-regexp-Fix-mistake-in-previous-commit.patch \
        file://backport-regexp-Fix-null-deref-in-xmlFAFinishReduceEpsilonTra.patch \
        file://backport-hash-Fix-possible-startup-crash-with-old-libxslt-ver.patch \
        file://backport-parser-Fix-old-SAX1-parser-with-custom-callbacks.patch \
        file://backport-xmllint-Fix-use-after-free-with-maxmem.patch \
        file://backport-malloc-fail-Check-for-malloc-failures-when-creating.patch \
        file://backport-malloc-fail-Fix-buffer-overread-after-htmlParseScrip.patch \
        file://backport-xmlValidatePopElement-can-return-invalid-value-1.patch \
        file://backport-Fix-use-after-free-in-xmlParseContentInternal.patch \
        file://backport-malloc-fail-Fix-null-deref-after-xmlXIncludeNewRef.patch \
        file://backport-xpath-Ignore-entity-ref-nodes-when-computing-node-ha.patch \
        file://backport-SAX-Always-initialize-SAX1-element-handlers.patch \
        file://backport-CVE-2023-45322.patch \
        file://backport-CVE-2024-25062.patch \
        file://backport-CVE-2024-34459.patch \
        file://backport-xpath-Fix-build-without-LIBXML_XPATH_ENABLED.patch \
"

# checksum changed
SRC_URI[sha256sum] = "60d74a257d1ccec0475e749cba2f21559e48139efba6ff28224357c7c798dfee"

LIC_FILES_CHKSUM = "file://Copyright;md5=2044417e2e5006b65a8b9067b683fcf1 \
                    file://hash.c;beginline=6;endline=15;md5=e77f77b12cb69e203d8b4090a0eee879 \
                    file://list.c;beginline=4;endline=13;md5=b9c25b021ccaf287e50060602d20f3a7 \
                    file://trio.c;beginline=5;endline=14;md5=cd4f61e27f88c1d43df112966b1cd28f \
"

# remove python config, because openEuler not support python yet.
PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'python', 'python3', '', d)} \
		 ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
"

# remove test configuration, because test package not in openEuler
do_configure_remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
