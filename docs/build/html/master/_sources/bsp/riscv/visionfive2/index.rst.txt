.. _board_visionfive-v2:

visionfive-v2 sd卡镜像构建与使用
######################################

构建sd镜像
==================

1. 参照 :ref:`oebuild安装介绍<oebuild_install>` 完成oebuild安装，并详细了解构建过程。
2. 按照以下步骤，构建用于visionfive-v2的镜像：

  .. code-block:: console

    # 初始化一个oebuild目录
    oebuild init <oebuild_dir>
    cd <oebuild_dir>
    # 生成相应的构建目录
    oebuild generate -p visionfive2 -d <build_dir>
    cd build/<build_dir>
    # 启动构建容器
    oebuild bitbake
    # 容器内部构建os镜像
    bitbake openeuler-image

除了使用上述命令oebuild generate -p visionfive2 -d <build_dir>进行配置文件生成之外，还可以使用如下命令进入到菜单选择界面进行对应数据填写和选择，效果跟上述命令相同。

    .. code-block:: console

        oebuild generate

    具体界面如下图所示:

    .. image:: ../../../_static/images/generate/oebuild-generate-select.png

3. 构建生成的镜像在 ``<oebuild_dir>/build/<build_dir>/output/<generation_date>`` 目录下。
   是一个以wic.bz2结尾的文件。
4. 将此文件传输到能烧写sd卡的机器上，并解压为wic文件。
5. 通过 ``dd of=/dev/<sd_card_dev_name> if=/path/to/wic/file bs=<block size user want to sync>``，
   将wic文件烧录进入sd卡。

启动visionfive-v2
===================

visionfive-v2有4种 `启动模式 <https://doc.rvspace.org/VisionFive2/Developing_and_Porting_Guide/JH7110_Boot_UG/VisionFive2_SDK_QSG/boot_mode_settings.html>`_：

- Flash。visionfive-v2内置的flash里有SPL、openSBI和uboot，当拨码开关为“00”的时候，
  ROM会选择从flash启动。
- SD。当拨码开关为“01”的时候，从SD卡启动。地址0x00000000指向SD卡的起始地址。
- eMMC。当拨码开关为“10”的时候，从eMMC启动，地址0x00000000指向eMMC的起始地址。
- UART。当拨码开关为“11”的时候，从UART0启动。

当前yocto-meta-openeuler仓库里实现的启动方式，是使用第一种方式，即从flash启动。
flash里的uboot会依次遍历sd卡，eMMC和NVME，如果sd卡中有文件，则优先从sd卡启动。

当我们将 `拨码开关 <https://doc.rvspace.org/VisionFive2/Quick_Start_Guide/VisionFive2_QSG/board_apperance.html>`_
设置为“00”后，插入sd卡，并接通电源。启动信息会通过串口出现在屏幕上。
如果visionfive-v2已经接通电源，则插入sd卡后，按下reset按钮，
也能让系统重启。

.. note:: 

  visionfive-v2的串口通过引脚6、8、10进行转接。具体引脚分布见图1。
  visionfive-v2串口在openEuler Embedded中的设备为ttyS0，波特率为115200。

.. figure:: VF2_40pin.svg
  :align: center
  
  图1 visionfive-v2 引脚图