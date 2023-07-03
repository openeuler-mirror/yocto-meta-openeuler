require qt5-src.inc

SRC_URI:prepend = "file://0005-Scanner-Avoid-accessing-dangling-pointers-in-destroy.patch \
           file://0006-Make-setting-QT_SCALE_FACTOR-work-on-Wayland.patch \
           file://0007-Do-not-try-to-eglMakeCurrent-for-unintended-case.patch \
           file://0008-Make-setting-QT_SCALE_FACTOR-work-on-Wayland.patch \
           file://0009-Ensure-that-grabbing-is-performed-in-correct-context.patch \
           file://0010-Fix-leaked-subsurface-wayland-items.patch \
           file://0011-Use-qWarning-and-_exit-instead-of-qFatal-for-wayland.patch \
           file://0012-Fix-memory-leak-in-QWaylandGLContext.patch \
           file://0013-Client-Send-set_window_geometry-only-once-configured.patch \
           file://0014-Translate-opaque-area-with-frame-margins.patch \
           file://0015-Client-Send-exposeEvent-to-parent-on-subsurface-posi.patch \
           file://0016-Get-correct-decoration-margins-region.patch \
           file://0017-xdgshell-Tell-the-compositor-the-screen-we-re-expect.patch \
           file://0018-Fix-compilation.patch \
           file://0019-client-Allow-QWaylandInputContext-to-accept-composed.patch \
           file://0020-Client-Announce-an-output-after-receiving-more-compl.patch \
           file://0021-Fix-issue-with-repeated-window-size-changes.patch \
           file://0022-Include-locale.h-for-setlocale-LC_CTYPE.patch \
           file://0023-Client-Connect-drags-being-accepted-to-updating-the-.patch \
           file://0024-Client-Disconnect-registry-listener-on-destruction.patch \
           file://0025-Client-Set-XdgShell-size-hints-before-the-first-comm.patch \
           file://0026-Fix-build.patch \
           file://0027-Fix-remove-listener.patch \
           file://0028-Hook-up-queryKeyboardModifers.patch \
           file://0029-Do-not-update-the-mask-if-we-do-not-have-a-surface.patch \
           file://0030-Correctly-detect-if-image-format-is-supported-by-QIm.patch \
           file://qtwayland-client-expose-toplevel-window-state.patch \
           file://qtwayland-client-use-wl-keyboard-to-determine-active-state.patch \
           file://qtwayland-client-do-not-empty-clipboard-when-new-popup-or-window-is-opened.patch \
           "
