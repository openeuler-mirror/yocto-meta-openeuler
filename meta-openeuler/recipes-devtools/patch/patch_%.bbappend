
PV = "2.7.6"

# apply openeuler source package and patches
SRC_URI:prepend = "file://${BP}.tar.xz \
            file://backport-Fix-failed-assertion-outstate-after_newline.patch \
            file://backport-Add-missing-section-tests-to-context-format-test-cas.patch \
"

# unapplicable OE patches:
#             file://backport-Fix-test-for-presence-of-BASH_LINENO-0.patch 
#             file://backport-Pass-the-correct-stat-to-backup-files.patch 
# "
