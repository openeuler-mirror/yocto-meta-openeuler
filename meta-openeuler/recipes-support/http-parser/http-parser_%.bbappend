# source bb: meta-networking/recipes-support/http-parser/http-parser_2.9.4.bb;branch=master

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
		   file://backport-url-treat-empty-port-as-default.patch \
"

S = "${WORKDIR}/${BP}"

SRC_URI[md5sum] = "1b0f2371aabacbadaa03cc532cedcf92"
SRC_URI[sha256sum] = "467b9e30fd0979ee301065e70f637d525c28193449e1b13fbcb1b1fab3ad224f"
