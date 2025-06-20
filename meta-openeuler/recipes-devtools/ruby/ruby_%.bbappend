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
"

SRC_URI:remove = " \
           file://CVE-2023-28756.patch \
           file://CVE-2023-28755.patch \
"

LIC_FILES_CHKSUM:remove = "file://LEGAL;md5=f260190bc1e92e363f0ee3c0463d4c7c"
LIC_FILES_CHKSUM:append = " file://LEGAL;md5=bcd74b47bbaf2051c5e49811a5faa97a"
