PV = "3.2.2"

# openeuler src
# do not use ruby-2.1.0-custom-rubygems-location.patch, which will cause:
# ruby-3.2.2/tool/file2lastrev.rb:6:in `require': cannot load such file -- optparse (LoadError)
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://ruby-2.3.0-ruby_version.patch \
        file://ruby-2.1.0-Prevent-duplicated-paths-when-empty-version-string-i.patch \
        file://ruby-2.1.0-Enable-configuration-of-archlibdir.patch \
        file://ruby-2.1.0-always-use-i386.patch \
        file://ruby-2.7.0-Initialize-ABRT-hook.patch \
        file://ruby-2.7.1-Timeout-the-test_bug_reporter_add-witout-raising-err.patch \
        file://backport-CVE-2019-19204.patch \
        file://backport-CVE-2019-19246.patch \
        file://backport-CVE-2019-16161.patch \
        file://backport-CVE-2019-16162.patch \
        file://backport-CVE-2019-16163.patch \
        file://backport-CVE-2023-36617.patch \
        file://backport-CVE-2024-27281.patch \
        file://backport-CVE-2024-27282.patch \
        file://backport-rubygems-rubygems-Drop-to-support-Psych-3.0-bundled-.patch \
        file://backport-0001-CVE-2024-35221.patch \
        file://backport-0002-CVE-2024-35221.patch \
        file://backport-0003-CVE-2024-35221.patch \
        file://backport-0004-CVE-2024-35221.patch \
        file://backport-0005-CVE-2024-35221.patch \
        file://upgrade-lib-rexml-to-3.3.1.patch \
        file://backport-CVE-2024-41946.patch \
        file://backport-CVE-2024-39908-CVE-2024-41123-upgrade-lib-rexml-to-3.3.3.patch \
        file://backport-CVE-2024-43398-upgrade-lib-rexml-to-3.3.6.patch \
        file://backport-CVE-2024-47220.patch \
        file://backport-CVE-2024-49761.patch \
        file://backport-CVE-2025-25186.patch \
        file://backport-CVE-2025-27219.patch \
        file://backport-CVE-2025-27220.patch \
        file://backport-0001-CVE-2025-27221.patch \
        file://backport-0002-CVE-2025-27221.patch \
        file://backport-Add-response_handlers-kwarg-to-Net-IMAP.new.patch \
        file://backport-Reformat-get_response-debug-trace-printing.patch \
        file://backport-Anchor-literal-regexp-to-the-end-of-the-buffer.patch \
        file://backport-Extract-line-and-literal-parts-of-get_response.patch \
        file://backport-Allocate-string-literals-with-specific-capacity.patch \
        file://backport-Simplify-get_response-loop-further.patch \
        file://backport-Explicitly-throw-eof-for-EOF-in-get_response.patch \
        file://backport-Extract-ResponseReader-from-get_response.patch \
        file://backport-Save-ResponseReader-ivars-buff-literal_size.patch \
        file://backport-Fix-backport-compatibility-with-ruby-2.7.patch \
        file://backport-0001-CVE-2025-43857.patch \
        file://backport-0002-CVE-2025-43857.patch \
        file://backport-0003-CVE-2025-43857.patch \
        file://backport-0004-CVE-2025-43857.patch \
        file://backport-Add-IOSource-match-method-216.patch \
        file://backport-Use-StringScanner-peek_byte-to-get-double-or-single-.patch \
        file://backport-Reduced-regular-expression-processing-in-the-form-of.patch \
        file://backport-CVE-2025-58767.patch \
        file://backport-CVE-2025-61594.patch \
        file://backport-CVE-2026-41316.patch \
        file://backport-0001-CVE-2026-42246.patch \
        file://backport-0002-CVE-2026-42246.patch \
        file://backport-0003-CVE-2026-42246.patch \
        file://backport-0004-CVE-2026-42246.patch \
        file://backport-0001-CVE-2026-42245.patch \
        file://backport-0002-CVE-2026-42245.patch \
        file://backport-0003-CVE-2026-42245.patch \
        file://backport-edit-ca72ac45-Extract-superclass-for-internal-comman.patch \
        file://backport-pick-de70825ca-Validate-Literal-data-doesn-t-contain.patch \
        file://backport-pick-1eabb757e-Add-internal-binary-literal-support.patch \
        file://backport-pick-96fb12823-Add-ability-to-send-non-synchronizing.patch \
        file://backport-0001-CVE-2026-42257-CVE-2026-42258.patch \
        file://backport-0002-CVE-2026-42257-CVE-2026-42258.patch \
        file://backport-0003-CVE-2026-42257-CVE-2026-42258.patch \
        file://backport-0004-CVE-2026-42257-CVE-2026-42258.patch \
        file://backport-0005-CVE-2026-42257-CVE-2026-42258.patch \
        file://backport-CVE-2025-24294.patch \
        file://backport-CVE-2026-27820.patch \
        file://Add-greeting-code-data-to-responses.patch \
        file://Deprecate-client_thread-with-a-warning.patch \
        file://Update-responses-methods-for-thread-safety.patch \
        file://Add-cached-capabilities-capable-name-etc.patch \
        file://backport-0001-CVE-2026-47240-Validate-non-synchronizing-literals-support.patch \
        file://backport-0002-CVE-2026-47240-Extract-str.bytesize-lvar-in-send_literal.patch \
        file://backport-CVE-2026-47241-Prevent-trailing-0-in-RawData-validation.patch \
        file://backport-0001-CVE-2026-47242-Refactor-RawText-add-improve-test-coverage.patch \
        file://backport-0002-CVE-2026-47242-Validate-QuotedString-contains-only-valid-bytes.patch \
        file://backport-CVE-2026-80212.patch \
        file://backport-CVE-2026-80213.patch \
        file://backport-CVE-2026-82455.patch \
        file://backport-Check-the-resolved-parent-directory-before-extractin.patch \
        file://backport-ruby-net-http-Renew-test-certificates.patch \
        file://backport-ruby-net-http-Commented-out-unfinished-chunked-test.patch \
        file://backport-ruby-rubygems-Removed-credential-assertion-from-stdo.patch \
        file://backport-ruby-openssl-Only-CSR-version-1-encoded-as-0-is-allo.patch \
        file://backport-ruby-openssl-test_asn1.rb-Remove-the-assertions-of-t.patch \
        file://backport-Omit-a-broken-https-test-on-MinGW.patch \
        file://backport-Omit-test_session_reuse_but_expire-if-OpenSSL-3.2.0.patch \
        file://backport-Fix-test-session-reuse-but-expire-9824.patch \
        file://backport-ruby-net-http-Skip-test_session_reuse_but_expire-wit.patch \
        file://backport-ruby-net-http-test_https.rb-fix-test_session_reuse_b.patch \
        file://fix-dynamic-constant-assignment-SyntaxError.patch \
"

SRC_URI:remove = " \
           file://CVE-2023-28756.patch \
           file://CVE-2023-28755.patch \
"

LIC_FILES_CHKSUM:remove = "file://LEGAL;md5=f260190bc1e92e363f0ee3c0463d4c7c"
LIC_FILES_CHKSUM:append = " file://LEGAL;md5=bcd74b47bbaf2051c5e49811a5faa97a"
