# in release 10, add more patches
SRC_URI_append = "\
    file://backport-Add-a-buffer-limit-just-in-case.patch \
    file://backport-Teardown-SIGCONT-watcher-on-exit.patch \
    file://backport-Correct-path-of-config-file.patch \
    file://backport-Fix-the-error-found-by-clang-tidy-313.patch \
    file://backport-Fix-segfault-in-python-bindings-around-the-feed-API.patch \
    file://backport-Rewrite-legacy-service-functions-in-terms-of-systemc.patch \
    file://backport-Error-out-if-required-zos-parameters-missing.patch \
    file://backport-Fix-deprecated-python-function.patch \
    file://backport-lib-close-audit-socket-in-load_feature_bitmap-334.patch \
    file://backport-lib-enclose-macro-to-avoid-precedence-issues.patch \
    file://backport-memory-allocation-updates-341.patch \
    file://backport-lib-cast-to-unsigned-char-for-character-test-functio.patch \
    file://backport-Make-session-id-consistently-typed-327.patch \
    file://backport-Avoid-file-descriptor-leaks-in-multi-threaded-applic.patch \
    file://backport-fix-the-use-of-isdigit-everywhere.patch \
    file://backport-Fix-new-warnings-for-unused-results.patch \
    file://backport-Change-the-first-iteration-test-so-static-analysis-b.patch \
    file://backport-Consolidate-end-of-event-detection-to-a-common-funct.patch \
    file://backport-Issue343-Fix-checkpoint-issue-to-ensure-all-complete.patch \
    file://backport-lib-avoid-UB-on-sequence-wrap-around-347.patch \
    file://backport-Change-python-bindings-to-switch-from-PyEval_CallObj.patch \
    file://backport-Cleanup-shell-script-warnings.patch \
"
