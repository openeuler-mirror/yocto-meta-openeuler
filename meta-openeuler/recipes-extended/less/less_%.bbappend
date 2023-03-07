# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "608"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://LICENSE;md5=38fc26d78ca8d284a2a5a4bbc263d29b \
                    "

# Use the source packages and patches from openEuler
# less-475-fsync.patch can't apply: cannot run test program while cross compiling
SRC_URI_remove = "file://less-475-fsync.patch"

SRC_URI += "file://less-394-time.patch \
            file://less-475-fsync.patch \
            file://backport-makecheck-0000-add-lesstest.patch \
            file://backport-makecheck-0001-Work-on-lesstest-remove-rstat-add-LESS_DUMP_CHAR.patch \
            file://backport-makecheck-0002-lesstest-correctly-handle-less-exit-during-run_inter.patch \
            file://backport-makecheck-0003-Some-runtest-tweaks.patch \
            file://backport-makecheck-0004-Rearrange-signal-handling-a-little.patch \
            file://backport-makecheck-0005-Don-t-setup_term-in-test-mode.patch \
            file://backport-makecheck-0006-Compile-fixes.patch \
            file://backport-makecheck-0007-Pass-less-specific-env-variables-to-lesstest-get-rid.patch \
            file://backport-makecheck-0008-Move-terminal-init-deinit-to-run_interactive-since.patch \
            file://backport-makecheck-0009-Fix-bug-in-setting-env-vars-from-lt-file-in-test-mod.patch \
            file://backport-makecheck-0010-Make-runtest-work.patch \
            file://backport-makecheck-0011-lesstest-in-interactive-mode-call-setup_term-before-.patch \
            file://backport-makecheck-0012-lesstest-log-LESS_TERMCAP_-vars-so-termcap-keys-etc.patch \
            file://backport-makecheck-0013-lesstest-accommodate-stupid-termcap-design-where-the.patch \
            file://backport-makecheck-0014-lesstest-maketest-should-not-overwrite-existing-lt-f.patch \
            file://backport-makecheck-0015-lesstest-add-O-option-to-maketest-if-textfile-is-not.patch \
            file://backport-makecheck-0016-lesstest-add-O-option-to-lesstest.patch \
            file://backport-makecheck-0017-lesstest-handle-colored-text-with-less-R.patch \
            file://backport-makecheck-0018-lesstest-add-e-option.patch \
            file://backport-makecheck-0019-lesstest-split-display_screen-into-display_screen_de.patch \
            file://backport-makecheck-0020-Add-E-option.patch \
            file://backport-makecheck-0021-Consistent-style.patch \
            file://backport-makecheck-0022-Obsolete-file.patch \
            file://backport-makecheck-0023-Tuesday-style.patch \
            file://backport-makecheck-0024-Tuesday-style.patch \
            file://backport-makecheck-0025-lesstest-add-support-for-combining-and-composing-cha.patch \
            file://backport-makecheck-0026-Minor-runtest-output-tweaks.patch \
            file://backport-makecheck-0027-lesstest-lt_screen-should-clear-param-stack-after-pr.patch \
            file://backport-makecheck-0028-Handle-fg-and-bg-colors.patch \
            file://backport-makecheck-0029-Have-lt_screen-use-ANSI-sequences-for-bold-underline.patch \
            file://backport-makecheck-0030-ESC-m-should-clear-attributes-as-well-as-colors.patch \
            file://backport-makecheck-0031-lesskey-make-lt_screen-treat-ESC-0m-like-ESC-m.patch \
            file://backport-makecheck-0032-Store-2-char-hex-values-in-log-file-rather-than-bina.patch \
            file://backport-makecheck-0033-lesstest-Make-display_screen_debug-write-to-stderr-n.patch \
            file://backport-makecheck-0034-lesstest-Clear-screen-at-end-of-maketest-in-case-ter.patch \
            file://backport-makecheck-0035-lesstest-Verify-that-the-less-binary-is-built-with-D.patch \
            file://backport-makecheck-0036-Add-check-target-to-Makefile-to-run-lesstest.patch \
            file://backport-makecheck-0037-Don-t-set-LESS_TERMCAP_xx-environment-vars-from-term.patch \
            file://backport-makecheck-0038-lesstest-Remove-unnecessary-exit_all_modes-field-fro.patch \
            file://backport-makecheck-0039-lesstest-Add-some-initial-lt-files.patch \
            file://backport-makecheck-0040-lesstest-Remove-empty-lt-file.patch \
            file://backport-makecheck-0041-lesstest-Add-a-couple-more-lt-files.patch \
            file://backport-makecheck-0042-Make-make-check-work-regardless-of-directory-where-l.patch \
            file://backport-End-OSC8-hyperlink-on-invalid-embedded-escape-sequen.patch \
            "

SRC_URI[md5sum] = "1cdec714569d830a68f4cff11203cdba"
SRC_URI[sha256sum] = "a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"
