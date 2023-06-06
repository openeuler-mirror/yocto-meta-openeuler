# main bbfile: yocto-poky/meta/recipes-extended/sed/sed_4.8.bb

# patches in openeuler
SRC_URI += " \
        file://backport-sed-handle-very-long-execution-lines-tiny-change.patch \
        file://backport-sed-handle-very-long-input-lines-with-R-tiny-change.patch \
        file://backport-maint-avoid-new-warning-about-deprecated-security_co.patch \
        file://backport-maint-update-obsolete-constructs-in-configure.ac.patch \
        file://backport-sed-avoid-potential-double-fclose.patch \
        file://backport-sed-fix-temp-file-cleanup.patch \
        file://backport-sed-c-flag.patch \
"
