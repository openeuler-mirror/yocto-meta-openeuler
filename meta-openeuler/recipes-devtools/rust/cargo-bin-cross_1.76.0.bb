# This file is developed based on meta-rust-bin(https://github.com/rust-embedded/meta-rust-bin) 
# using MIT License
# 
# Copyright © 2016 meta-rust-bin author
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the “Software”), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.

# This corresponds to cargo release 1.76.0

OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR = "rust"

def get_by_triple(hashes, component, triple):
    try:
        return hashes[triple]
    except:
        raise bb.parse.SkipRecipe("Unsupported triple: %s-%s" % (component, triple))

# for native tools, openeuler yocto build docker only support x86_64 host
def cargo_url(triple):
    URLS = {
        "x86_64-unknown-linux-gnu": "file://oee_archive/rust/cargo-${PV}-x86_64-unknown-linux-gnu.tar.xz",
    }
    return get_by_triple(URLS, "cargo_url", triple)

DEPENDS += "rustc-bin-cross-${TARGET_ARCH} (= 1.76.0)"

require cargo-bin-cross.inc
