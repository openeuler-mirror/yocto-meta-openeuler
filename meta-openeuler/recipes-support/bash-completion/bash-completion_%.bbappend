# version in openEuler
PV = "2.11"

# add patches in openEuler
SRC_URI += "file://bash-completion-remove-python2.patch \
    file://bash-completion-remove-redundant-python2-links.patch \
"
