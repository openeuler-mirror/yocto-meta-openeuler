# main bbfile: yocto-poky/meta/recipes-support/attr/attr_2.5.1.bb

# attr version in openEuler
PV = "2.5.1"

SRC_URI += " \
            file://${BP}.tar.gz \
            file://0001-bypass-wrong-output-when-enabled-selinux.patch \
            file://0002-dont-skip-security.evm-when-copy-xattr.patch \
            file://0003-attr-eliminate-a-dead-store-in-attr_copy_action.patch \
            file://0004-fix-stale-attr-references.patch \
            file://0005-use-run-as-the-filename-extension-for-run-test-sc.patch \
            file://0006-fix-test-suite-for-selinux.patch \
            file://0007-add-visibility-attribute-header.patch \
            file://0008-add-xattrat-syscall-wrappers.patch \
            file://0009-add-xattrat-syscall-backwards-compatibility-code.patch \
            file://0010-rename-walk_tree-to-old_walk_tree.patch \
            file://0011-add-the-new-walk_tree-helper.patch \
            file://0012-harden-getfattr.patch \
            file://0013-setfattr-multiple-restore-accesses-freed-buffer.patch \
            file://0014-setfattr-do-not-ignore-no-dereference-after-resto.patch \
            file://0015-add-openat2-syscall-wrapper.patch \
            file://0016-harden-setfattr-restore.patch \
"

ASSUME_PROVIDE_PKGS = "attr"
