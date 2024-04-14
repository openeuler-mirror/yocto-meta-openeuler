require cmake-src.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

LIC_FILES_CHKSUM:remove = " \
    file://Utilities/cmjsoncpp/LICENSE;md5=fa2a23dd1dc6c139f35105379d76df2b \
    file://Utilities/cmlibuv/LICENSE;md5=a68902a430e32200263d182d44924d47 \
"
LIC_FILES_CHKSUM:append = " \
    file://Utilities/cmjsoncpp/LICENSE;md5=5d73c165a0f9e86a1342f32d19ec5926 \
    file://Utilities/cmlibuv/LICENSE;md5=ad93ca1fffe931537fcf64f6fcce084d \
    file://Utilities/cmcurl/COPYING;md5=db8448a1e43eb2125f7740fc397db1f6 \
"

# from cmake-native_3.27.7.bb
SRC_URI:remove = "file://0001-CMakeDetermineSystem-use-oe-environment-vars-to-load.patch"
SRC_URI:append = " file://0001-CMakeLists.txt-disable-USE_NGHTTP2.patch"

CMAKE_EXTRACONF += "\
    -DCMAKE_USE_SYSTEM_LIBRARY_CPPDAP=0 \
    -DCMAKE_USE_SYSTEM_LIBRARY_CURL=0 \
"
CMAKE_EXTRACONF:remove = "-DCURL_LIBRARIES=-lcurl"

DEPENDS:remove = "curl-native"
DEPENDS += "openssl-native"

do_configure () {
	${S}/bootstrap --verbose --prefix=${prefix} \
		${@oe.utils.parallel_make_argument(d, '--parallel=%d')} \
		${@bb.utils.contains('CCACHE', 'ccache ', '--enable-ccache', '', d)} \
		-- ${CMAKE_EXTRACONF}
}
