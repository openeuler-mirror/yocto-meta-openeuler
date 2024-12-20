PV = "20230802.1"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://abseil-cpp-20210324.2-sw.patch \
        file://0001-add-loongarch-suopport-for-abseil-cpp.patch \
        file://0002-PR-1644-unscaledcycleclock-remove-RISC-V-support.patch \
        "

EXTRA_OECMAKE += " \
	-DABSL_ENABLE_INSTALL=ON \
	-DCMAKE_SHARED_LINKER_FLAGS="-Wl,--as-needed" \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
"

S = "${WORKDIR}/${BP}"
