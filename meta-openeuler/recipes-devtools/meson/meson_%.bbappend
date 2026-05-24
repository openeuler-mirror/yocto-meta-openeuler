PV = "1.11.1"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

# Remove patches written for the upstream 1.1.1 base recipe that don't apply to 1.11.1
SRC_URI:remove = "file://0001-Make-CPU-family-warnings-fatal.patch \
                  file://0001-python-module-do-not-manipulate-the-environment-when.patch \
                  file://0002-Support-building-allarch-recipes-again.patch"
