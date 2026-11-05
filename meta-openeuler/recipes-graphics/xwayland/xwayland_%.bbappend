
PV = "22.1.2"

# full CVE backport series from the src repo spec
SRC_URI:prepend = "file://${BP}.tar.xz \
    file://0001-fix-CVE-2024-31080.patch \
    file://0002-fix-CVE-2024-31081.patch \
    file://0003-fix-CVE-2023-6377.patch \
    file://0004-fix-CVE-2023-6478.patch \
    file://0005-fix-CVE-2023-6816.patch \
    file://0006-fix-CVE-2024-0408.patch \
    file://0007-fix-CVE-2024-0409.patch \
    file://0008-fix-CVE-2024-0229-1.patch \
    file://0009-fix-CVE-2024-0229-2.patch \
    file://0010-fix-CVE-2024-0229-3.patch \
    file://0011-fix-CVE-2024-31083.patch \
    file://0012-fix-CVE-2022-2320.patch \
    file://0013-fix-CVE-2025-49175.patch \
    file://0014-fix-CVE-2025-49176.patch \
    file://0015-fix-CVE-2025-49177.patch \
    file://0016-fix-CVE-2025-49178.patch \
    file://0017-fix-CVE-2025-49179.patch \
    file://0018-fix-CVE-2025-49180.patch \
    file://0019-fix-CVE-2025-26595.patch \
    file://0020-fix-CVE-2026-33999.patch \
    file://0021-fix-CVE-2026-34001.patch \
    file://0022-fix-CVE-2025-62229.patch \
    file://0023-fix-CVE-2026-34002.patch \
    file://0024-fix-CVE-2026-34003-1.patch \
    file://0025-fix-CVE-2026-34003-2.patch \
    file://backport-CVE-2026-50262.patch \
    file://0027-fix-CVE-2026-50261.patch \
    file://backport-CVE-2025-62231.patch \
    file://backport-CVE-2026-50257-50260.patch \
    file://backport-CVE-2026-50258.patch \
    file://backport-CVE-2026-50259.patch \
    file://backport-CVE-2026-50263.patch \
    file://backport-CVE-2026-55999.patch \
    file://backport-CVE-2024-9632.patch \
    file://0028-fix-CVE-2025-26596.patch \
    file://0036-fix-CVE-2025-26597.patch \
    file://0037-fix-CVE-2025-26598.patch \
    file://0038-fix-CVE-2025-26599.patch \
    file://0039-fix-CVE-2025-26601.patch \
    file://0040-fix-CVE-2025-26600.patch \
    file://0041-fix-CVE-2025-26594.patch \
    file://0042-fix-CVE-2025-62230-1.patch \
    file://0043-fix-CVE-2025-62230-2.patch \
    file://0044-fix-CVE-2026-50256.patch \
    file://0045-fix-CVE-2026-88812.patch \
    file://0046-fix-CVE-2026-93515.patch \
    file://0047-fix-CVE-2026-93516.patch \
    file://0048-fix-CVE-2026-93517.patch \
    file://0049-fix-CVE-2026-93518.patch \
    file://0050-fix-CVE-2026-93519-1.patch \
    file://0051-fix-CVE-2026-93519-2.patch \
    file://0052-fix-CVE-2026-93519-3.patch \
    file://0053-fix-CVE-2026-93520.patch \
    file://0054-fix-CVE-2026-93521.patch \
    file://0055-fix-CVE-2026-93523.patch \
    file://0056-fix-CVE-2026-93524.patch \
    file://0057-fix-CVE-2026-93536.patch \
           "
