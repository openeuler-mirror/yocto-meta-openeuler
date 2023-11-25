# in release 10, add more patches
SRC_URI_append = "\
    file://backport-Add-a-buffer-limit-just-in-case.patch \
    file://backport-Teardown-SIGCONT-watcher-on-exit.patch \
    file://backport-Correct-path-of-config-file.patch \
    "