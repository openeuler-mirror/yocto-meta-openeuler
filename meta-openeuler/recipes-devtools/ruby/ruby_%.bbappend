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
"

SRC_URI:remove = " \
           file://CVE-2023-28756.patch \
           file://CVE-2023-28755.patch \
"

LIC_FILES_CHKSUM:remove = "file://LEGAL;md5=f260190bc1e92e363f0ee3c0463d4c7c"
LIC_FILES_CHKSUM:append = " file://LEGAL;md5=bcd74b47bbaf2051c5e49811a5faa97a"
