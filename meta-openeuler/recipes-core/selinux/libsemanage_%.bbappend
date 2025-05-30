
PV = "3.5"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=a6f89e2100d9b6cdffcea4f398e37343"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://backport-libsemanage-direct_api-INTEGER_OVERFLOW-read_len-rea.patch \
        file://backport-libsemanage-open-lock_file-with-O_RDWR.patch \
        file://backport-libsemanage-check-memory-allocations.patch \
        file://backport-libsemanage-free-resources-on-failed-connect-attempt.patch \
        file://backport-libsemanage-fix-asprintf-error-branch.patch \
        file://backport-libsemanage-avoid-leak-on-realloc-failure.patch \
        file://backport-libsemanage-free-ibdev-names-in-semanage_ibendport_v.patch \
        file://backport-libsemanage-check-for-path-formatting-failures.patch \
        file://backport-libsemanage-set-O_CLOEXEC-flag-for-file-descriptors.patch \
        file://backport-libsemanage-check-closing-written-files.patch \
        file://backport-libsemanage-handle-cil_set_handle_unknown-failure.patch \
        file://backport-libsemanage-handle-shell-allocation-failure.patch \
        file://backport-libsemanage-drop-duplicate-newlines-and-error-descriptions-in-error-messages.patch \
        file://backport-libsemanage-simplify-file-deletion.patch \
        file://backport-libsemanage-optimize-policy-by-default.patch \
        file://fix-test-failure-with-secilc.patch \
        "

S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "libsemanage"
