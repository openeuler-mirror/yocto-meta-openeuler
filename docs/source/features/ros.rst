.. _ros_runtime_embedded:

嵌入式ROS运行时支持
####################


总体介绍
==========================

机器人尤其服务机器人领域近年来发展迅速，ROS（Robot Operating System）作为一个适用于机器人的开源中间件框架，已经在众多领域得到广泛应用。然而，常规的ROS系统存在较多的平台约束，通常与Ubuntu等桌面操作系统
强依赖，这限制了其在更广泛的嵌入式设备上的应用。ROS目前有两个主要版本，ROS1和ROS2。ROS1于2010年发布，ROS2于2017年发布，ROS2相较于ROS1有较大的改进，详细介绍请参考 `ROS2入门教程 <https://book.guyuehome.com/>`_ 。

为了使ROS2能够在高度定制化的嵌入式Linux系统上运行，通过Yocto项目构建的meta-ROS层成为了关键途径。meta-ROS为ROS2提供了必要的软件包配方和配置，使其能够适配基于Yocto的嵌入式Linux系统。

尽管meta-ROS层为ROS2支持提供了基础，但其应用门槛较高，且未充分考虑嵌入式运行时的关键场景要素，如实时性能和资源限制。这使得开发者在将ROS2应用于嵌入式项目时面临挑战。

openEuler Embedded对ROS2的运行时支持，旨在提高易用性、解决高门槛问题的同时，构建机器人嵌入式运行时的竞争力。openEuler Embedded通过简化ROS2的集成流程、提供实时性能优化和小型化支持，使得ROS2能
够在资源受限的嵌入式设备上高效运行。

框架
=========================

openEuler Embedded中ROS2运行时整体架构图如下所示，分为运行视图和构建视图，构建视图总体基于开源meta-ros layer `meta-ros <https://github.com/ros/meta-ros/>`_ 作为基础。

    .. figure:: ../../image/ros/plan_ros_architecture.png
        :align: center

        图 1 openEuler Embedded中ROS运行时支持基础架构

其中，

**meta-openuler层** 提供依赖解耦和嵌入式定制(针对编译类、观测类、仿真类等工具对onboard/运行时部署进行解耦)，负责镜像快速集成和SDK工具的生成。

**ros2recipe模块** 提供了第三方ros源码到yocto配方的转换工具（不同于社区原生meta-ros生成工具superflore），作为meta-openeuler镜像快速集成的输入。

**快速开发SDK模块** 提供了第三方ros源码到运行时应用的交叉编译转化。

**运行时优化模块** 联通OS侧特性，链接混合关键部署等RTOS实时及总线能力，最终提供复杂系统的实时和通信解决方案。


镜像构建指南
==============

openEuler Embedded 支持ROS运行时相关组件的单独构建和镜像集成构建案例。

**构建指导**

使用oebuild进行构建即可，具体使用方式参照oebuild指导，构建qemu-ros参照如下命令:

  .. code-block:: console

    $ oebuild generate -p qemu-aarch64 -f openeuler-ros -d aarch64-qemu-ros
    $ oebuild bitbake
    $ bitbake openeuler-image


构建树莓派参照如下命令

  .. code-block:: console

    $ oebuild generate -p raspberrypi4-64 -f openeuler-ros -d raspberrypi4-64-ros
    $ oebuild bitbake
    $ bitbake openeuler-image

除了使用上述命令进行配置文件生成之外，还可以使用如下命令进入到菜单选择界面进行对应数据填写和选择，此菜单选项可以替代上述命令中的oebuild generate，选择保存之后继续执行上述命令中的bitbake及后续命令即可。

    .. code-block:: console

        oebuild generate

    具体界面如下图所示:

    .. image:: ../_static/images/generate/oebuild-generate-select.png

.. note:: 
    * 当前只要开启了ros特性，openeuler-image镜像会默认集成ros-core核心功能

    * 基于树莓派的ROS特性镜像还加入了SLAM典型功能（相关导航和制图典型场景功能正在完善中，欢迎试用和加入贡献）

    * 另外按照嵌入式运行时原则，请尽量不在目标系统中集成编译类、观测类、仿真类等更适合在开发主机上运行的工具

    **注意** ：
     pcl点云库比较耗编译主机的内存资源，对该库进行了线程限制（-j 2），可参见对应pcl的bbappend配方。
     另外，虽已限制在(-j 2)，其编译所需的主机内存要求需大于等于14G（加上swap空间）。
     若您的编译主机配置足够，可解开（-j 2）限制，例如在16线程32GB内存的机器解除限制后无法成功编译，
     在24线程64GB内存的机器上测试可解除线程限制成功编译。


镜像使用示例
============

以qemu-aarch64和originbot小车（树莓派作为主控板）为例:

**1.QEMU多机部署和demo_nodes_cpp示例**

  - **step1: 部署两个QEMU机器**

    在host中创建网桥br0

    .. code-block:: console

        brctl addbr br0

    启动qemu1

    .. code-block:: console

        qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
        -kernel zImage \
        -initrd <openeuler-image-qemu-xxx.cpio.gz> \
        -device virtio-net-device,netdev=tap0,mac=52:54:00:12:34:56 \
        -netdev bridge,id=tap0

    .. attention::

        首次运行如果出现如下错误提示

        .. code-block:: console

            failed to parse default acl file `/usr/local/libexec/../etc/qemu/bridge.conf'
            qemu-system-aarch64: bridge helper failed

        则需要向指示的文件添加"allow br0"：

        .. code-block:: console

            echo "allow br0" > /usr/local/libexec/../etc/qemu/bridge.conf

    启动qemu2

    .. code-block:: console

        qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
        -kernel zImage \
        -initrd openeuler-image-qemu-aarch64-2023xxx.rootfs.cpio.gz \
        -device virtio-net-device,netdev=tap1,mac=52:54:00:12:34:78 \
        -netdev bridge,id=tap1

    .. attention::

        qemu1与qemu2的mac地址需要配置为不同的值。


    配置IP

    配置host的网桥地址

    .. code-block:: console

        ifconfig br0 192.168.10.1 up

    配置qemu1的网络地址

    .. code-block:: console

        ifconfig eth0 192.168.10.2

    配置qemu2的网络地址

    .. code-block:: console

        ifconfig eth0 192.168.10.3

  - **step2: 分别在两个QEMU机器中运行demo_nodes_cpp发布和订阅**

    qemu1执行

    .. code-block:: console

      # ROS环境变量初始化
      $ source /etc/profile.d/ros/setup.bash

      # demo消息订阅
      $ ros2 run demo_nodes_cpp listener

    qemu2执行

    .. code-block:: console

      # ROS环境变量初始化
      $ source /etc/profile.d/ros/setup.bash

      # demo消息发布
      $ ros2 run demo_nodes_cpp talker

  .. note:: 
    
    单机通信同理，在同一台设备上通过多个终端分别执行demo_nodes_cpp发布和订阅即可，属于ROS常规用法，不再详述。


**2.originbot小车制图和导航示例（树莓派作为主控板）**

  - **step1: originbot小车雷达USB、底盘驱动板串口完成连接**

    以树莓派作为主控板为例，假如雷达使用USB串口且对应设备为ttyUSB0、底盘串口使用GPIO 14/15且对应ttyS0

    .. note:: 

        以上串口设备为示例配置，雷达串口号和originbot底盘串口号用户可自行修改配置，配置文件位置例（直接修改即生效）：

        /usr/share/originbot_base/launch/robot.launch.py

        /usr/share/originbot_bringup/param/ydlidar.yaml

  - **step2: 环境准备，并配置originbot小车和观测PC处于同一网段**

    以树莓派作为主控板通过无线网络连接为例（可使用无线路由器或无线热点，需要小车和观测PC处于同一个网段）

    openEuler Embedded树莓派使能无线连接参见 :ref:`openEuler Embedded网络配置-Wi-Fi网络配置 <network_config_wifi>`

    .. note:: 

      观测PC可为ubuntu，需要安装ROS和oringbot观测端，参见：

      `PC端ubuntu ROS2安装 <http://originbot.org/guide/pc_config/#2-ros2>`_

      `PC端ubuntu oringbot安装 <http://originbot.org/guide/pc_config/#3-pc>`_

  - **step3: 通过观测PC，远程ssh登录originbot小车，执行运行时ROS应用**

    以建图为例，整体过程和originbot官网过程一样，可参考

    `originbot 启动底盘和雷达 <http://originbot.org/application/slam/#1>`_

    `originbot 启动SLAM <http://originbot.org/application/slam/#2-slam>`_

    首先，ssh登录originbot小车终端1，执行如下命令：

    .. code-block:: console

        # ROS环境变量初始化
        $ source /etc/profile.d/ros/setup.bash
        # 启动机器人底盘和激光雷达：
        $ ros2 launch originbot_bringup originbot.launch.py use_lidar:=true

    然后，ssh登录originbot小车终端2，执行如下命令：

    .. code-block:: console

        # ROS环境变量初始化
        $ source /etc/profile.d/ros/setup.bash
        # 启动cartographer建图算法：
        $ ros2 launch originbot_navigation cartographer.launch.py


  - **step4: 在观测端PC，启动上位机可视化软件以便查看SLAM的完整过程，同时启动上位机键盘控制远程小车**

    整体过程和originbot官网过程一样，可参考

    `originbot 上位机可视化显示 <http://originbot.org/application/slam/#3>`_

    `originbot 上位机键盘控制小车建图 <http://originbot.org/application/slam/#4>`_

    首先，观测端PC开启一个终端，进入ROS环境后启动rviz观测软件

    .. code-block:: console

        $ ros2 launch originbot_viz display_slam.launch.py

    然后，观测端PC开启另一个终端，进入ROS环境后启动键盘控制节点用于控制小车，并按照提示控制小车完成建图

    .. code-block:: console

        $ ros2 run teleop_twist_keyboard teleop_twist_keyboard

  - **step5: 保存运行时数据（建图数据等）**

    以建图保存为例，整体过程和originbot官网过程一样，可参考

    `originbot 保存地图 <http://originbot.org/application/slam/#5>`_

    不要关闭之前步骤的端口，ssh登录originbot小车终端3，执行如下命令

    .. code-block:: console

        # ROS环境变量初始化
        $ source /etc/profile.d/ros/setup.bash
        # 保存地图：
        $ ros2 run nav2_map_server map_saver_cli -f my_map --ros-args -p save_map_timeout:=10000

  .. figure:: ../../image/ros/slam_demo1.png
        :align: center

  .. figure:: ../../image/ros/slam_demo2.png
        :align: center

        图 2 openEuler Embedded中ROS SLAM DEMO示例

  .. note::
      其他应用如导航类似，请直接参考orinbot官方资料。如自主导航，将建好的地图至于对应包位置即可，
      参见 `originbot 自主导航 <http://originbot.org/application/navigation/>`_


快速开发SDK
=================

**使用说明**

openEuler Embedded支持ROS2快速开发SDK，目前支持在主机或者oebuild初始化的容器中，通过安装构建生成的SDK，对ROS包进行快速交叉编译。目前支持colcon编译工具，和基础colcon用法一致。

**使用约束**

和常规colcon一样，我们支持了colcon交叉编译基本框架，不过由于ROS2软件包的语言和依赖库多种多样，目前仅支持C/C++/Python三种常用语言的软件包，而类似RUST等依赖cargo的软件包还不支持。欢迎开发者持续贡献openEuler Embedded社区。

**使用方法**

**1. 在构建完成镜像后，通过populate_sdk生成SDK**

  .. code-block:: console

    # 以树莓派ROS2镜像为例
    $ oebuild generate -p raspberrypi4-64 -f openeuler-ros -d raspberrypi4-64-ros
    $ oebuild bitbake
    # 在conf/local.conf中，设置 OPENEULER_PREBUILT_TOOLS_ENABLE = "no" ,这样就可以尽可能
    # 生成nativesdk所需要的工具
    $ bitbake openeuler-image
    $ bitbake openeuler-image -c populate_sdk

  .. note::
    如果要使用ROS2 SDK，请确认 :file:`conf/local.conf` 中OPENEULER_PREBUILT_TOOLS_ENABLE = "no" ，只有这样SDK中才会包含
    colcon, cmake, python, make等主机工具，可以进行ROS2应用的开发。

  随后在 :file:`output/[时间戳]/` 目录下即可找到对应SDK安装文件，例如

  .. code-block:: console
    
    openeuler-glibc-x86_64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-24.03.sh


**2. SDK的安装和初始化**

  已获得SDK的上层应用开发者，可直接从此节开始进行参考

  (1). 安装1中生成的SDK的sh安装脚本

  假设SDK脚本位于目录:file:`/home/openeuler/build/raspberrypi4-64/output/20230523023324``

  .. code-block:: console

    $ cd /home/openeuler/build/raspberrypi4-64/output/20230523023324
    $ ./openeuler-glibc-x86_64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-23.03.sh
    # 输入安装目录，假设为“/home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk”，目录请事先创建好，按“y”确认
    $ /home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk
    $ y

  (2). 根据提示执行SDK初始化
  
  .. code-block:: console

    $ . /home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk/environment-setup-cortexa72-openeuler-linux
  
  此外，除了初始化上述SDK的环境变量，您无需额外source ros.setup等ROS工作空间，在SDK内部，我们已经准备好了，而SDK提供的colcon，会将colcon命令执行目录自动作为ROS的新增工作空间。


**3. 通过colcon交叉编译ROS包**

  您只需要进入到ros包工程或colcon工程的工作路径，执行colcon进行编译即可，将自动进行交叉编译。

  .. code-block:: console

    $ cd your_rospkg_workspace
    $ colcon build --cmake-args -DBUILD_TESTING=False
    # 注： 这里--cmake-args -DBUILD_TESTING=False 参数是必要项，顾名思义，是为了禁止做不必要的构建时测试，构建时测试需不适用于SDK，且SDK没有集成相关组件。
    
  完成后，和colcon用法一样，在工作目录将生成install文件夹，即交叉编译的目标产物。


**4. 部署和运行（重要）**

  对于基于C/C++的ROS2软件包，colcon生成的install可以直接拷贝到目标机器上进行部署运行，
  通过如下命令在目标系统上进行工作目录的初始化：

  .. code-block:: console

    $ cd /ros_runtime/install
    $ source /etc/profile.d/ros/setup.bash # 初始化ROS工作目录
    $ source setup.bash # 将当前目录，加入到ROS的额外工作目录
  
  .. attention:: 
    
    请尽量使用setup.bash, 如果使用setup.sh, 需要提前设置COLCON_CURRENT_PREFIX变量为目标系统上的工作目录路径，如
    不设置，则setup.sh会使用开发主机上的工作目录路径，从而造成失败。

  对于基于python的ROS2软件包，并不会发生实际的构建，而是将python代码打包安装，但由于setuptool的限制，需要把install目录下
  由setuptool中easy install所生成的wrapper script中shebang行中指向的python解释器路径替换为目标机器上的python解释器路径，
  然后拷贝到目标机器上运行即可。具体以ROS2的demo_nodes_py为例，会在 :file:`/install/demo_nodes_py/lib/demo_nodes_py/` 下生成
  相应的wrapper script，就需要修改各个wrapper script中的shebang行中的python解释器路径。

  .. code-block:: python

    #!/home/openeuler/sdk/sysroots/x86_64-openeulersdk-linux/usr/bin/python3
    # EASY-INSTALL-ENTRY-SCRIPT: 'demo-nodes-py==0.20.5','console_scripts','talker'
    import re
    import sys


  改为

   .. code-block:: python

    #!/usr/bin/python3
    # EASY-INSTALL-ENTRY-SCRIPT: 'demo-nodes-py==0.20.5','console_scripts','talker'
    import re
    import sys 

关于ROS源码
=================

当前src-openeuler已集成ROS humble的所有软件源码，对应通过yocto-meta-openeuler/.oebuild/目录下的maplist.yaml和manifest.yaml可以查询源码包列表和基线。

所有ROS软件包，默认都加上了openeuler_source.bbclass，yocto构建时将自动映射软件包基线，若需定制且您有yocto经验，可参见相关实现: openeuler_source.bbclass


快速镜像集成(ros2recipe)
==========================

**现状:**
ros2recipe当前还处于前期开发阶段，在依赖解析部分还存在较多工作，其原理类似meta-ros的生成工具superflore。

**例子:**
我们在yocto工程中集成了originbot ros第三方包，其基础bb配方是通过ros2recipe工具转化，但目前还需要增加bbappend文件来适配部分依赖。

**其他说明:**
superfores能够实现以一个ROS版本生成全量官方ROS组件包，对整体ROS和oe层进行了复杂的依赖关联，但不支持将独立的第三方包转换为yocto配方。

针对该场景，ros2recipe如何能够更好更快的补全依赖关系、减少手工bbappend的适配，是一个很有挑战性的工作。需要大量的案例进行逐步完善，在此期待您的贡献。

**使用方法**

    .. code-block:: console

        yocto-meta-openeuler/scripts/ros2recipe.sh


ROS2 SDK上层开发者常见FAQ
============================

**问：我在开发容器中安装好了SDK，也编译过我的工程了，过了几天，我再进入容器再编译同样工程，却不行了?**

答：不管SDK安装在哪里（不管是否为容器和主机的共享目录），SDK会依赖容器中的非共享目录的配置内容，而容器如果没有及时保存(断电等原因)，包括环境变量的这些数据都会丢失。

在此建议您，如果关机后重启，建议重新安装SDK。且不管在任何场景，只要重新进入容器，都需要初始化SDK的环境变量。


**问：我在ubuntu中调试了一个ROS应用包，代码用SDK编译却报错头文件找不到，比如#include <nav_msgs/msg/odometry.hpp>，这是什么原因？**

答：您可以确认SDK的安装路径中，是否存在对应文件，比如odometry.hpp，您会发现对应文件存在于xxx/nav_msgs/nav_msgs/msg/odometry.hpp的目录，那么大概率是因为您的ROS应用包的CMakeLists.txt中缺少对nav_msgs的依赖描述

针对上面问题，请确保您的CMakeLists.txt配置文件中：(1)find_package(nav_msgs REQUIRED) (2)ament_target_dependencies([pkgname] xxxxx nav_msgs)包含nav_msgs的依赖信息。

而如果ubuntu没有问题，可能是因为ubuntu的依赖软件安装目录没有分离成独立目录，正好在inlcude所在的一级目录恰巧被找到了，而严谨的做法是需要在CMakeLists中描述清楚依赖的。
