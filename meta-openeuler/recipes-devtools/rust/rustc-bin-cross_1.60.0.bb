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

def get_by_triple(hashes, component, triple):
    try:
        return hashes[triple]
    except:
        raise bb.parse.SkipRecipe("Unsupported triple: %s-%s" % (component, triple))

def rust_std_md5(triple):
    HASHES = {
        "aarch64-unknown-linux-gnu": "8b833ed24714e4e3fa2007dd25bc84b4",
        "aarch64-unknown-linux-musl": "59c7157e37dfe682f78953d6298c9739",
        "arm-unknown-linux-gnueabi": "2d9d59506435a3818974fdb3d42afbd6",
        "arm-unknown-linux-gnueabihf": "4afbb11590395ea1b91923906c39a2a4",
        "armv7-unknown-linux-gnueabihf": "4b1625ccaac350176c225861cb035438",
        "armv7-unknown-linux-musleabihf": "7e1d13f25ba9c878695c6a850113ab30",
        "i686-unknown-linux-gnu": "2976701fa2745b4c98ca45af39367296",
        "x86_64-unknown-linux-gnu": "688fabc8b9db1ae9a06ccdd4b200ff95",
    }
    return get_by_triple(HASHES, "rust-std", triple)

def rust_std_sha256(triple):
    HASHES = {
        "aarch64-unknown-linux-gnu": "790b12924797dd00e550f3205c8f6403e73124b88de10a77b00830f67904630c",
        "aarch64-unknown-linux-musl": "1f023fb8e8d41451e503e1d194f674ba12b37da79612018d77dc13860b8b694d",
        "arm-unknown-linux-gnueabi": "9023211fc273ede0a2e80ebc2c78059a8211734a6f8bdf91853b165e70eaf58b",
        "arm-unknown-linux-gnueabihf": "edbb346595fc79131476ee09dd6cf97e6cf44682e34ebb950779b950301521ef",
        "armv7-unknown-linux-gnueabihf": "90218ecee6c67a8d3d8bc94022d6e0a66e9addbe6a6bfcfa8fd4977ff743496f",
        "armv7-unknown-linux-musleabihf": "ba8da062d443e4d148feb080b1245fb2fc2170def8cb8cd71248b95b33c93a91",
        "i686-unknown-linux-gnu": "95657c1f612115bdb434f8a0e049df058ac2d3d139f347aa01007aca82951615",
        "x86_64-unknown-linux-gnu": "963fd25a1f0e986a890e0f99f14902314c71e00f3b14bb587a08ca447ea7d1a6",
    }
    return get_by_triple(HASHES, "rust-std", triple)

def rustc_md5(triple):
    HASHES = {
        "aarch64-unknown-linux-gnu": "f13d49cea397bd748ea613c65d3f8fee",
        "arm-unknown-linux-gnueabi": "80617d9d10ef7a8d6ccd66e6308863f1",
        "arm-unknown-linux-gnueabihf": "5d823112d719df5e54a0726da8535cfa",
        "armv7-unknown-linux-gnueabihf": "2c5b930841a769495e22bbf53e73a719",
        "i686-unknown-linux-gnu": "f2d599a6c36d2973aab640ba8f79e7c9",
        "x86_64-unknown-linux-gnu": "9e3ddf8c08499f685ad36b72d417857a",
    }
    return get_by_triple(HASHES, "rustc", triple)

def rustc_sha256(triple):
    HASHES = {
        "aarch64-unknown-linux-gnu": "0e1ada844aa2f0fa9c1dcfd9352ddd400f67890131eb5873fd3e9ec700b911e1",
        "arm-unknown-linux-gnueabi": "dcab6611845e3a2bbcd59a6a238d4ee561736f138eea0b8a86fa04621aa7d9fd",
        "arm-unknown-linux-gnueabihf": "1fee8c2b6ca8d523a0b727b0819b3a92051ce4c5d8ea75e1df2021a1bce85e76",
        "armv7-unknown-linux-gnueabihf": "bfc8520dbb0bd27af75bfee3015c3e68a1f44d0e2ffaedd13082c7364c6f913f",
        "i686-unknown-linux-gnu": "04da8b7af94b9b6b0fe50b296ee69c2f26cd7341ff2a31686a66dffdc0d24ed5",
        "x86_64-unknown-linux-gnu": "d68a0566627ea0d481ee5e57c1bfc995c10ff55ffad34b2508c747429c3bbd6e",
    }
    return get_by_triple(HASHES, "rustc", triple)

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=93a95682d51b4cb0a633a97046940ef0"

require rustc-bin-cross.inc
