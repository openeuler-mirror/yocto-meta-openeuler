LOCAL_PATH := $(call my-dir)

dtbtool_src_files := \
        src/dtbtool.c

include $(CLEAR_VARS)

LOCAL_MODULE := dtbTool

LOCAL_SRC_FILES := $(dtbtool_src_files)

LOCAL_C_INCLUDES := 

#LOCAL_CFLAGS := -Wall -s -DNDEBUG -O1 -DSECUREC_SUPPORT_STRTOLD=1 -Werror
LOCAL_CFLAGS := -Wall -s -DNDEBUG -O1 

include $(BUILD_HOST_EXECUTABLE)

