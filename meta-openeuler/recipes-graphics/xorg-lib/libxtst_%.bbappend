require openeuler-xorg-lib-common.inc

PV = "1.2.4"

SRC_URI:append = " \
  file://backport-Coverity-CID-1373522-Fix-memory-leak.patch \
" 
SRC_URI[sha256sum] = "01366506aeb033f6dffca5326af85f670746b0cabbfd092aabefb046cf48c445"
