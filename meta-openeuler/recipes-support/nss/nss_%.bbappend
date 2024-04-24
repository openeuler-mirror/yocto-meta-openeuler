PV = "3.94"

LIC_FILES_CHKSUM = "file://nss/COPYING;md5=3b1e88e1b9c0b5a4b2881d46cce06a18 \
                    file://nss/lib/freebl/mpi/doc/LICENSE;md5=491f158d09d948466afce85d6f1fe18f \
                    file://nss/lib/freebl/mpi/doc/LICENSE-MPL;md5=5d425c8f3157dbf212db2ec53d9e5132 \
                    file://nss/lib/freebl/verified/Hacl_Poly1305_256.c;beginline=1;endline=22;md5=cc22f07b95d28d56baeb757df46ee7c8"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://Feature-nss-add-implement-of-SM3-digest-algorithm.patch;patchdir=nss \
    file://Feature-nss-add-implement-of-SM2-signature-algorithm.patch;patchdir=nss \
    file://Feature-nss-support-SM3-digest-algorithm.patch;patchdir=nss \
    file://Feature-nss-support-SM2-signature-algorithm.patch;patchdir=nss \
    file://Feature-nss-fix-the-certificate-resolution-in-sm2.patch;patchdir=nss \
    file://Feature-fix-sm2-sm3-code-error.patch;patchdir=nss \
    file://Feature-fix-sm3-code-error.patch;patchdir=nss \
"

