require qt5-src.inc

SRC_URI:prepend = "file://0005-QQuickView-docs-show-correct-usage-of-setInitialProp.patch \
           file://0006-QQuickWindow-Check-if-QQuickItem-was-not-deleted.patch \
           file://0007-Avoid-GHS-linker-to-optimize-away-QML-type-registrat.patch \
           file://0008-QML-Text-doesn-t-reset-lineCount-when-text-is-empty.patch \
           file://0009-Doc-mention-that-INCLUDEPATH-must-be-set-in-some-cas.patch \
           file://0010-qmlfunctions.qdoc-Add-clarification-to-QML_FOREIGN.patch \
           file://0011-Fix-QML-property-cache-leaks-of-delegate-items.patch \
           file://0012-QQuickTextInput-Store-mask-data-in-std-unique_ptr.patch \
           file://0013-Fix-crash-when-calling-hasOwnProperty-on-proxy-objec.patch \
           file://0014-Accessibility-event-is-sent-on-item-s-geometry-chang.patch \
           file://0015-qmltypes.prf-Take-abi-into-account-for-_metatypes.js.patch \
           file://0016-qv4qmlcontext-Fix-bounded-signal-expressions-when-de.patch \
           file://0017-Use-load-qt_tool-for-qmltime.patch \
           file://0018-qqmlistmodel-Fix-crash-when-modelCache-is-null.patch \
           file://0019-Show-a-tableview-even-if-the-syncView-has-an-empty-m.patch \
           file://0020-DesignerSupport-Don-t-skip-already-inspected-objects.patch \
           file://0021-QML-Fix-proxy-iteration.patch \
           file://0022-Fix-IC-properties-in-same-file.patch \
           file://0023-JIT-When-making-memory-writable-include-the-exceptio.patch \
           file://0024-doc-explain-QQItem-event-delivery-handlers-setAccept.patch \
           file://0025-Give-a-warning-when-StyledText-encounters-a-non-supp.patch \
           file://0026-Add-missing-limits-include-to-fix-build-with-GCC-11.patch \
           file://0027-Document-that-StyledText-also-supports-nbsp-and-quot.patch \
           file://0028-Support-apos-in-styled-text.patch \
           file://qt5-qtdeclarative-gcc11.patch \
           file://qtdeclarative-5.15.0-FixMaxXMaxYExtent.patch \
           "
