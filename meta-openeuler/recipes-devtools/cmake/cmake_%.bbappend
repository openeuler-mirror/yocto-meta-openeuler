require cmake-src.inc

EXTRA_OECMAKE += " \
	-DCMAKE_USE_SYSTEM_LIBRARY_CPPDAP=0 \
	-DCMake_ENABLE_DEBUGGER=0 \
"
LIC_FILES_CHKSUM:remove = " \
	file://Utilities/cmjsoncpp/LICENSE;md5=fa2a23dd1dc6c139f35105379d76df2b \
	file://Utilities/cmlibuv/LICENSE;md5=a68902a430e32200263d182d44924d47 \
"
LIC_FILES_CHKSUM:append = " \
	file://Utilities/cmjsoncpp/LICENSE;md5=5d73c165a0f9e86a1342f32d19ec5926 \
	file://Utilities/cmlibuv/LICENSE;md5=ad93ca1fffe931537fcf64f6fcce084d \
"
