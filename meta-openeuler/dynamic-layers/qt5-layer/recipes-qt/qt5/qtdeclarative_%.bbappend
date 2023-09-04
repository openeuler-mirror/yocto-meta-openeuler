require qt5-src.inc

SRC_URI:prepend = "file://0001-Remove-unused-QPointer-QQuickPointerMask.patch \
           file://0002-QQmlDelegateModel-Refresh-the-view-when-a-column-is-.patch \
           file://0003-Fix-TapHandler-so-that-it-actually-registers-a-tap.patch \
           file://0004-Revert-Fix-TapHandler-so-that-it-actually-registers-.patch \
           file://0005-Make-sure-QQuickWidget-and-its-offscreen-window-s-sc.patch \
           file://0006-QQuickItem-Guard-against-cycles-in-nextPrevItemInTab.patch \
           file://0007-Don-t-convert-QByteArray-in-startDrag.patch \
           file://0008-Fix-build-after-95290f66b806a307b8da1f72f8fc2c698019.patch \
           file://0009-Implement-accessibility-for-QQuickWidget.patch \
           file://0010-Send-ObjectShow-event-for-visible-components-after-i.patch \
           file://0011-QQuickItem-avoid-emitting-signals-during-destruction.patch \
           file://0012-a11y-track-item-enabled-state.patch \
           file://0013-Make-QaccessibleQuickWidget-private-API.patch \
           file://0014-Qml-Don-t-crash-when-as-casting-to-type-with-errors.patch \
           file://0015-Fix-missing-glyphs-when-using-NativeRendering.patch \
           file://0016-Revert-Fix-missing-glyphs-when-using-NativeRendering.patch \
           file://0017-QQmlImportDatabase-Make-sure-the-newly-added-import-.patch \
           file://0018-QQuickState-when-handle-QJSValue-properties-correctl.patch \
           file://0019-Models-Avoid-crashes-when-deleting-cache-items.patch \
           file://0020-qv4function-Fix-crash-due-to-reference-being-invalid.patch \
           file://0021-Quick-Animations-Fix-crash.patch \
           file://0022-Prevent-crash-when-destroying-asynchronous-Loader.patch \
           file://0023-QQuickItem-Fix-effective-visibility-for-items-withou.patch \
           file://0024-Revert-QQuickItem-Fix-effective-visibility-for-items.patch \
           file://0025-Accessibility-respect-value-in-attached-Accessible-i.patch \
           file://0026-qml-tool-Use-QCommandLineParser-process-rather-than-.patch \
           file://qt5-qtdeclarative-gcc11.patch \
           file://qtdeclarative-5.15.0-FixMaxXMaxYExtent.patch \
           file://qt-QTBUG-111935-fix-V4-jit.patch \
           "
