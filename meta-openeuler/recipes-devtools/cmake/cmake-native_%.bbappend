require cmake-src.inc

# from cmake-native_3.27.7.bb
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
