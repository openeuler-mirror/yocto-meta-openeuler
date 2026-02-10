add_subdirectory(src)

set(DTS_BASE_DIR ${TOP_DIR}/dts)
if(PRODUCT STREQUAL "aaaaaa310Besl" OR
   PRODUCT STREQUAL "aaaaaa310B" OR
   PRODUCT STREQUAL "aaaaaa310Bemu" OR
   PRODUCT STREQUAL "aaaaaa310Brc" OR
   PRODUCT STREQUAL "aaaaaa310Brcesl" OR
   PRODUCT STREQUAL "aaaaaa310Brcemu")
    # 当前driver跟esl用相同的dts，后期需要更新到单独的目录
    set(DTS_SRC_DIR ${DTS_BASE_DIR}/hi1910b/hi1910BL)
    set(DTS_FILE_LIST hi1910B-default.dts)
    set(OUT_DT_IMAGE dt.img)
elseif(PRODUCT STREQUAL "aaaaaa310prc")
    set(DTS_SRC_DIR ${DTS_BASE_DIR}/helper)
    set(DTS_FILE_LIST hi1910P-default.dts)
    set(OUT_DT_IMAGE dt.img)
else()
    message(FATAL_ERROR "unsupported chip '${PRODUCT}' for device_dtb target")
endif()

# 编译单个dtb文件
set(DTB_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/dtbs)
if(PRODUCT STREQUAL "aaaaaa111A" AND (ENABLE_KASAN OR ENABLE_ASAN))
    add_custom_command(OUTPUT ${DTB_OUT_DIR}
        # KASAN requires a lot of memory, we need to make HBM available to the os
        COMMAND sed -i '/hotpluggable/d' ${DTS_SRC_DIR}/asic/*-asic-kernel*.dtsi
        COMMAND sed -i "'/memory_crash/ahotpluggable;'" ${DTS_SRC_DIR}/asic/*-asic-kernel*.dtsi
        COMMAND pushd ${DTS_SRC_DIR} && sed -i "s/cma=[0-9]*M //g" ${DTS_FILE_LIST} && popd
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/mkdtb.sh ${DTB_OUT_DIR} ${DTS_SRC_DIR} ${DTS_FILE_LIST}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/mkdtb.sh
    )
else()
    add_custom_command(OUTPUT ${DTB_OUT_DIR}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/mkdtb.sh ${DTB_OUT_DIR} ${DTS_SRC_DIR} ${DTS_FILE_LIST}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/mkdtb.sh
    )
endif()
add_custom_target(dtb_single_files DEPENDS ${DTB_OUT_DIR})

# 编译dt.img
set(OUT_DT_IMAGE ${CMAKE_CURRENT_BINARY_DIR}/${OUT_DT_IMAGE})
add_custom_command(OUTPUT ${OUT_DT_IMAGE}
    COMMAND ${BIN_DTBTOOL} -o ${OUT_DT_IMAGE} ${DTB_OUT_DIR}/
    DEPENDS private_target_dtbtool dtb_single_files
)
add_custom_target(device_dtb DEPENDS ${OUT_DT_IMAGE})

install(DIRECTORY ${DTB_OUT_DIR}/
    DESTINATION bin
    OPTIONAL
)

install(FILES ${OUT_DT_IMAGE} ${dtb_single_files}
    DESTINATION bin
    OPTIONAL
)

