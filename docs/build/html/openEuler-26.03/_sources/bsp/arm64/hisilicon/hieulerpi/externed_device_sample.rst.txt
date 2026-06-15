.. _board_hieulerpi_device_sample:

海鸥派镜像驱动测试
##########################################

本章主要介绍海鸥派的驱动测试程序。

硬件外设参考 :ref:`board_hieulerpi_hardware_features`


海鸥派的驱动测试程序使用说明
====================================

1. 环境准备

   参考 :ref:`board_hieulerpi_build` 准备开发板环境。



2. 音频测试

   测试前将带麦克风的耳机接入开发板音频输入输出接口。

   .. code-block:: console

      export LD_LIBRARY_PATH=/usr/lib
      cd /root/device/sample
      ./audio_sample <index>
      index and its function list below
        0:  start AI to AO loop
        1:  send audio frame to AENC channel from AI, save them
        2:  read audio stream from file, decode and send AO
        3:  read audio stream from Mydream44100.aac file, decode and send AO
        4:  start AI(VQE process), then send to AO

3. HDMI测试

   测试前将显示器和开发板用HDMI2.0线接好。

   .. code-block:: console

      export LD_LIBRARY_PATH=/usr/lib
      cd /root/device/sample
      ./audio_hdmi
      hdmi_cmd:
         help                 list all command we provide
         q                    quit sample test
         hdmi_hdmi_force      force to hdmi output
         hdmi_dvi_force       force to enter dvi output mode
         hdmi_deepcolor       set video deepcolor mode
         hdmi_video_timing    set video output timing format
         hdmi_color_mode      set video color output(RGB/ycbcr)
         hdmi_aspectratio     set video aspectratio
         hdmi_a_freq          set audio output frequence
         hdmi_authmode        authmode enable or disable
