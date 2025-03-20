# Use the code from openEuler
PV = "9.0.2092"
S = "${WORKDIR}/vim-${PV}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=d1a651ab770b45d41c0f8cb5a8ca930e"

SRC_URI = " \
	file://vim-${PV}.tar.gz \
	file://vim-7.0-fixkeys.patch \
	file://vim-7.4-specsyntax.patch \
	file://vim-7.4-fstabsyntax.patch \
	file://vim-7.4-globalsyntax.patch \
	file://vim-8.0-copy-paste.patch \
	file://vim-python3-tests.patch \
	file://vim-9.0-spec-recognize-epoch.patch \
	file://backport-CVE-2023-48233.patch \
	file://backport-CVE-2023-48231.patch \
	file://backport-CVE-2023-48234.patch \
	file://backport-CVE-2023-48235.patch \
	file://backport-CVE-2023-48236.patch \
	file://backport-CVE-2023-48237.patch \
	file://backport-patch-9.0.2114-overflow-detection-not-accurate-when-adding.patch \
	file://backport-CVE-2023-48706.patch \
	file://backport-patch-9.0.2123-Problem-with-initializing-the-length-of-range-lists.patch \
	file://backport-vim-7.0-rclocation.patch \
	file://backport-CVE-2024-22667.patch \
	file://backport-CVE-2023-48232.patch \
	file://backport-patch-9.1.0265-console-dialog-cannot-save-unnamed-bu.patch \
	file://backport-patch-9.1.0267-File-name-entered-in-GUI-dialog-is-ig.patch \
	file://backport-CVE-2024-41965.patch \
	file://backport-patch-9.1.0554-bw-leaves-jumplist-and-tagstack-data-.patch \
	file://backport-CVE-2024-41957.patch \
	file://backport-CVE-2024-43374.patch \
	file://backport-CVE-2024-43802.patch \
	file://backport-patch-9.1.0722-crash-with-large-id-in-text_prop-interface.patch \
	file://backport-patch-9.1.0730-crash-with-cursor-screenline-and-narrow-window.patch \
	file://backport-patch-9.1.0918-tiny-vim-crashes-with-fuzzy-buffer-completion.patch \
	file://backport-patch-9.1.0038-Unnecessary-loop-in-getvcol.patch \
	file://backport-CVE-2025-22134.patch \
	file://backport-CVE-2025-24014.patch \
	file://backport-CVE-2025-1215.patch \
	file://backport-CVE-2025-26603.patch \
	file://bugfix-rm-modify-info-version.patch \
	file://fix-CVE-2024-47814.patch \
	"
