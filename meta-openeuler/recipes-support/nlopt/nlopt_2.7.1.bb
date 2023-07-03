SUMMARY = "NLopt: A library for nonlinear optimization, \
	   wrapping many algorithms for global and local, \
	   constrained or unconstrained, optimization"
DESCRIPTION = "NLopt is a library for nonlinear local and global optimization, \
	       for functions with and without gradient information. \
	       It is designed as a simple, unified interface and packaging of \
	       several free/open-source nonlinear optimization libraries."
HOMEPAGE = "https://nlopt.readthedocs.io/en/latest/"
SECTION = "libs"
LICENSE = "LGPLv2.1+"
LIC_FILES_CHKSUM = "file://COPYING;md5=7036bf07f719818948a837064b1af213"

PV = "2.7.1"
# matches with: https://github.com/stevengj/nlopt/releases/tag/v2.7.1
SRC_URI = "file://nlopt-${PV}.tar.gz"

SRC_URI[md5sum] = "ed1a3000a1c8c248d51df126dfcfaa78"
SRC_URI[sha256sum] = "db88232fa5cef0ff6e39943fc63ab6074208831dc0031cf1545f6ecd31ae2a1a"

RPROVIDES:${PN} = "nlopt"

inherit cmake
EXTRA_OECMAKE += "-DCMAKE_SKIP_RPATH=TRUE"
