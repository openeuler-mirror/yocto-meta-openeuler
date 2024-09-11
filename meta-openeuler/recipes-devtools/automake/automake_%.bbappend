PV = "1.17"

SRC_URI = "file://${BP}.tar.xz \
"

SRC_URI[sha256sum] = "f01d58cd6d9d77fbdca9eb4bbd5ead1988228fdb73d6f7a201f5f8d6b118b469"

# note: The path to the perl command is set upstream as "${USRBINPATH}/env perl", but for some
# reason it gets converted to "/usr/bin/env \nperl" when executing configure, which results in
# an error like "configure: error: The path to # your Perl contains spaces or tabs". Therefore,
# we temporarily specify the perl command path directly and will  modify it back once we find
# the root cause of the issue.
PERL:class-nativesdk = "${USRBINPATH}/perl"
