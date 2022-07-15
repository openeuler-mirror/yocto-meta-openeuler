PV = "3.7"

SRC_URI += " \
    file://backport-grep-avoid-sticky-problem-with-f-f.patch \
    file://backport-grep-s-does-not-suppress-binary-file-matches.patch \
"

SRC_URI[sha256sum] = "5c10da312460aec721984d5d83246d24520ec438dd48d7ab5a05dbc0d6d6823c"
