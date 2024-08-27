
PV = "2.15"

# upstream src and patches
SRC_URI = " file://${BP}.tar.bz2 \
            file://cpio-2.9-rh.patch \
            file://cpio-2.13-exitCode.patch \
            file://cpio-2.13-dev_number.patch \
            file://cpio-2.9.90-defaultremoteshell.patch \
            file://cpio-2.10-patternnamesigsegv.patch \
            file://cpio-2.10-longnames-split.patch \
            file://cpio-2.11-crc-fips-nit.patch \
            file://backport-Do-not-set-exit-code-to-2-when-failing-to-create-symlink.patch \
            file://add-option-to-add-metadata-in-copy-out-mode.patch \
            file://Fix-use-after-free-and-return-appropriate-error.patch \
"

SRC_URI[sha256sum] = "efa50ef983137eefc0a02fdb51509d624b5e3295c980aa127ceee4183455499e"
