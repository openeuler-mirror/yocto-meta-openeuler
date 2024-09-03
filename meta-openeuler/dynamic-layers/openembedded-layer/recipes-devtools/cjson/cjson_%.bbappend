
PV = "1.7.15"

SRC_URI = "file://v${PV}.tar.gz \
	file://backport-CVE-2023-50471_50472.patch \
	file://backport-fix-potential-memory-leak-in-merge_patch.patch \
        file://CVE-2024-31755.patch \
        file://Fix-a-null-pointer-crash-in-cJSON_ReplaceItemViaPoin.patch \
        file://backport-fix-add-allocate-check-for-replace_item_in_object-67.patch \
        file://backport-fix-print-int-without-decimal-places-630.patch \
        file://backport-Add-test-for-heap-buffer-overflow.patch \
        file://backport-Fix-heap-buffer-overflow.patch \
        file://backport-Set-free-d-pointers-to-NULL-whenever-they-are-not-re.patch \
"

S = "${WORKDIR}/cJSON-${PV}"
