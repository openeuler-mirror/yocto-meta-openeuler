#!/bin/bash
#----------------------------------------------------------------------------
# packaging images.
# Copyright Technologies Co., Ltd. 2010-2018. All rights reserved.
# Author: yaoliujie
#----------------------------------------------------------------------------
set -e

TOP_DIR = ""
KERNEL_OUT = ""
DTBTOOL =  $(TOP_DIR)/$(KERNEL_OUT)/release_imgs/dtbTool
KERNEL_DIR = $(TOP_DIR)/kernel/linux-4.1

$(DTBTOOL) -o dtb.img -s 2048 -p $(KERNEL_DIR)/scripts/dtc/ $(KERNEL_OUT)/release_imgs/*.dtb
