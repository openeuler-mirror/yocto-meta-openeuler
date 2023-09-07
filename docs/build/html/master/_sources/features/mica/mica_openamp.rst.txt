.. _mica_openamp:

基于openAMP的混合部署实现
#############################

构建指南
========

openEuler Embedded 不仅支持混合关键性系统特性的单独构建，还实现了集成构建，能够使用同一套工具链一键式构建出包含linux, zephyr的部署镜像。

.. note:: 单独构建混合关键系统特性的方法请参考 `mcs 构建安装指导 <https://gitee.com/openeuler/mcs#%E6%9E%84%E5%BB%BA%E5%AE%89%E8%A3%85%E6%8C%87%E5%AF%BC>`_

**集成构建指导**

1. 根据 :ref:`oebuild快速构建 <openeuler_embedded_oebuild>` ，初始化oebuild工作目录；

   .. code-block:: shell

      oebuild init <directory>
      cd <directory>
      oebuild update

2. 下载依赖代码：

   zephyr 的构建包含核心部分和外部 zephyr modules 部分，由于全部代码较大，需要从 `src-openEuler/zephyr <https://gitee.com/src-openeuler/zephyr>`_ 中的百度网盘路径下载 zephyr_project_v3.2.0.tar.gz，并放在构建代码目录下的 zephyrproject 子目录中（对应oebuild工作目录的<workspace>/src/zephyrproject）

   python3-pykwalify 在 openeuler 社区尚无相应的源码包，需要从上游下载 `Download pykwalify-1.8.0.tar.gz <https://pypi.org/project/pykwalify/1.8.0/#files>`_ ，并放在构建代码目录下的 python3-pykwalify 子目录中（对应oebuild工作目录的<workspace>/src/python3-pykwalify）

3. 进入oebuild工作目录，创建对应的编译配置文件，**mcs镜像需要添加** ``-f openeuler-mcs``：

   .. code-block:: shell

      # qemu-arm64
      oebuild generate -p qemu-aarch64 -f openeuler-mcs -d <build_arm64_mcs>

      # RPI4
      oebuild generate -p raspberrypi4-64 -f openeuler-mcs -d <build_rpi_mcs>

      # ok3568
      oebuild generate -p ok3568 -f openeuler-mcs -d <build_ok3568_mcs>

      # hi3093
      oebuild generate -p hi3093 -f openeuler-mcs -d <build_hi3093_mcs>

4. 进入 ``<build>`` 目录，编译 ``openeuler-image-mcs`` ：

   .. code-block:: shell

      oebuild bitbake openeuler-image-mcs

.. note::

   **注意**：构建 openeuler-image-mcs 需要在 oebuild 初始化时添加 ``-f openeuler-mcs``。

使用方法
========

目前混合关键性系统（mcs）支持在qemu-aarch64和树莓派上部署运行，部署mcs需要预留出必要的内存、CPU资源，并且还需要bios提供psci支持。

1.镜像启动
  - **对于树莓派:**

     集成构建出来的 openeuler-image-mcs 已经通过 dt-overlay 等方式预留了相关资源，并且默认使用了支持psci的uefi引导固件。因此只需要根据 :ref:`openeuler-image-uefi启动使用指导 <raspberrypi4-uefi-guide>` 进行镜像启动，再部署mcs即可。
  - **对于qemu:**

     需要准备一份dtb文件，dtb文件的制作可参考 `配置dts预留出mcs_mem <https://gitee.com/openeuler/mcs#%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E>`_ ，并通过以下命令启动qemu：

     .. code-block:: console

       $ qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a57 -nographic \
       -append 'maxcpus=3' -smp 4 \
       -kernel zImage \
       -initrd *.rootfs.cpio.gz \
       -dtb qemu_mcs.dtb
  - **对于ok3568:**

     已经通过条件判断的形式把预留内存加入了设备树，构建出来即可使用。
  - **对于hi3093:**

     hi3093需要在boot以后限制maxcpus=3预留出一个cpu跑uniproton

     .. code-block:: console

       # 使用在ctrl+b进入uboot，并限制启动的cpu数量
       setenv bootargs "${bootargs} maxcpus=3"

2.部署mcs
  - **step1: 调整内核打印等级并插入内核模块**

     .. code-block:: console

        # 为了不影响shell的使用，先屏蔽内核打印：
        $ echo "1 4 1 7" > /proc/sys/kernel/printk

        # 插入内核模块
        $ modprobe mcs_km.ko

        # 备注：ok3568与hi3093已经实现了开机自动加载内核模块，无需重复此步骤

     插入内核模块后，可以通过 `cat /proc/iomem` 查看预留出来的 mcs_mem，如：

     .. code-block:: console

        qemu-aarch64 ~ # cat /proc/iomem
        ...
        70000000-7fffffff : reserved
        70000000-7fffffff : mcs_mem
        ...

     若mcs_km.ko插入失败，可以通过dmesg看到对应的失败日志，可能的原因有：1.使用的交叉工具链与内核版本不匹配；2.未预留内存资源；3.使用的bios不支持psci

  - **step2: 运行rpmsg_main程序，启动client os**

     - **qemu-arm64 和 RPI4：**

       .. code-block:: console

          $ rpmsg_main -c [cpu_id] -t [target_binfile] -a [target_binaddress]
          eg:
          $ rpmsg_main -c 3 -t /firmware/zephyr-image.bin -a 0x7a000000

       若rpmsg_main成功运行，会有如下打印：

       .. code-block:: console

          # rpmsg_main -c 3 -t /firmware/zephyr-image.bin -a 0x7a000000
          ...
          start client os
          ...
          pls open /dev/pts/1 to talk with client OS
          pty_thread for uart is runnning
          ...

       此时， **按ctrl-c可以通知client os下线并退出rpmsg_main** ，下线后支持重复拉起。
       也可以根据打印提示（ ``pls open /dev/pts/1 to talk with client OS`` ），
       通过 /dev/pts/1 与 client os 进行 shell 交互，例如：

       .. code-block:: console

          # 新建一个terminal，登录到运行环境
          $ ssh user@ip

          # 连接pts设备
          $ screen /dev/pts/1

          # 敲回车后，可以打开client os的shell，对client os下发命令，例如
          uart:~$ help
          uart:~$ kernel version

          #在ok3568上拉起rt-thread
          $ rpmsg_main -c 3 -t /firmware/rtthread-ok3568.bin -a 0x7a000000

          #在hi3093上拉起uniproton
          $ rpmsg_main -c 3 -t /firmware/Uniproton_hi3093.bin -a 0x93000000

     - **ok3568 开发板：**

       ok3568支持通过mcs拉起 RT-Thread，步骤如下：

       .. code-block:: console

          # 拉起RTT；
          ok3568 ~ # ./rpmsg_main -c 3 -t /firmware/rtthread-ok3568.bin -a 0x7a000000
          ...
          start client os
          ...

       ok3568支持通过输入功能编号进行交互、下线、重新拉起:

       .. code-block:: console

          # 输入h查看用法
          h
          please input number:<1-8>
          1. test echo
          2. send matrix
          3. start pty
          4. close pty
          5. shutdown clientOS
          6. start clientOS
          7. test ping
          8. test flood-ping
          9. exit

     - **hi3093 开发板：**

       hi3093目前支持 uniproton 的拉起，查看串口输出。

       .. code-block:: console

          # 拉起 uniproton
          $ ./rpmsg_main -c 3 -t /firmware/hi3093_ut.bin -a 0x93000000 &

          ...
          start client os
          ...
          pls open /dev/pts/1 to talk with client OS
          pty_thread for console is runnning
          ...

       此时， 根据打印提示（ ``pls open /dev/pts/1 to talk with client OS`` ），
       通过 /dev/pts/1 可以与 uniproton 进行交互，例如：

       .. code-block:: console

          # 连接pts设备
          $ screen /dev/pts/1

          # 敲回车后，可以查看uniproton输出信息

