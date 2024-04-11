PV = "20230802.1"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://abseil-cpp-20210324.2-sw.patch \
        "

EXTRA_OECMAKE += " \
	-DABSL_ENABLE_INSTALL=ON \
	-DCMAKE_SHARED_LINKER_FLAGS="-Wl,--as-needed" \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
"

S = "${WORKDIR}/${BP}"
