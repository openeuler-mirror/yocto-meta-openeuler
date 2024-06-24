.. _ros_runtime_embedded:

嵌入式ROS运行时支持
####################


总体介绍
==========================

机器人尤其服务机器人领域近年来发展迅速，ROS是一个适用于机器人的开源的元操作系统，已在众多领域被广泛应用，常规ROS存在较多平台约束，大多与ubuntu等desktop版本强依赖。

随着ROS1开始广泛融入各领域无人系统的研发，系统的诸多问题陆续暴露出来。为了适应新时代机器人研发的和操作系统生态发展的需要，ROS2应运而生。

为使能ROS2在高度定制化的嵌入式Linux运行，支持通过yocto构建的meta-ROS（原LG维护）layer层成为嵌入式ROS支持的关键途径。然而，当前原生meta-ros应用门槛较高且未充分考虑嵌入式运行时的关键场景要素。

openEuler Embedded的嵌入式ROS运行时支持意在提高易用性、解决高门槛问题的同时，构建嵌入式运行时竞争力（如实时、小型化等）。

框架
=========================

openEuler Embedded中ROS运行时整体架构图如下所示，分为运行视图和构建视图，构建视图总体基于开源meta-ros layer `meta-ros <https://github.com/ros/meta-ros/>`_ 作为基础。

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
    $ bitbake openeuler-image-ros


构建树莓派参照如下命令

  .. code-block:: console

    $ oebuild generate -p raspberrypi4-64 -f openeuler-ros -d raspberrypi4-64-ros
    $ oebuild bitbake
    $ bitbake openeuler-image-ros

除了使用上述命令进行配置文件生成之外，还可以使用如下命令进入到菜单选择界面进行对应数据填写和选择，此菜单选项可以替代上述命令中的oebuild generate，选择保存之后继续执行上述命令中的bitbake及后续命令即可。

    .. code-block:: console

        oebuild generate

    具体界面如下图所示:

    .. image:: ../_static/images/generate/oebuild-generate-select.png

.. note:: 当前openeuler-image-ros镜像默认集成ros-core核心功能

    基于树莓派的openeuler-image-ros镜像还加入了SLAM典型功能
    （相关导航和制图典型场景功能正在完善中，欢迎试用和加入贡献）

    另外按照嵌入式运行时原则，将尽量不在target集成编译类、观测类、仿真类等工具

    | 注意：
    | pcl点云库比较耗编译主机的内存资源，对该库进行了线程限制（-j 2），可参见对应pcl的bbappend配方。
    | 另外，虽已限制在(-j 2)，其编译所需的主机内存要求需大于等于14G（加上swap空间）。
    | 若您的编译主机配置足够，可解开（-j 2）限制。
    | 参考：
    | 在16线程32GB内存的机器解除限制后无法成功编译；
    | 在24线程64GB内存的机器上测试可解除线程限制成功编译。


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

  .. note:: 单机通信同理，在同一台设备上通过多个终端分别执行demo_nodes_cpp发布和订阅即可，属于ROS常规用法，不再详述。


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

      `PC端ubuntu ros安装 <http://originbot.org/guide/pc_config/#2-ros2>`_

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

  .. note:: 其他应用如导航类似，请直接参考orinbot官方资料。如

      自主导航，将建好的地图至于对应包位置即可，参见 `originbot 自主导航 <http://originbot.org/application/navigation/>`_


快速开发SDK
=================

**使用说明**

版本新增支持快速开发SDK，目前支持在oebuild初始化的容器中，通过安装构建生成的SDK，对ROS包进行快速交叉编译。目前支持colcon编译工具，和基础colcon用法一致。

**使用约束**

和常规colcon一样，我们支持了colcon交叉编译基本框架，不过由于ROS2软件包的语言和依赖库多种多样，目前仅支持C/C++/Python三种常用语言的软件包，而类似RUST等依赖cargo的软件包还不支持。欢迎开发者持续贡献openEuler Embedded社区。

**使用方法**

**1. 在构建完成镜像后，通过populate_sdk生成SDK**

  .. code-block:: console

    # 以树莓派ROS2镜像为例
    $ oebuild generate -p raspberrypi4-64 -f openeuler-ros -d raspberrypi4-64-ros
    $ oebuild bitbake
    $ bitbake openeuler-image
    $ bitbake openeuler-image -c populate_sdk

  随后在“output/[时间戳]/”目录下即可找到对应SDK安装文件，例如

  .. code-block:: console
    
    openeuler-glibc-x86_64-openeuler-image-ros-cortexa72-raspberrypi4-64-toolchain-23.03.sh


**2. SDK的安装和初始化——已获得SDK的上层开发者，可直接从此章节开始进行参考**

  目前可用oebuild初始化的构建容器作为开发容器（后续会推出专用SDK的一站式oebuild功能，敬请期待），开发容器和构建容器可通用。

  (0). 前置准备——此过程重新罗列容器的准备过程，如您已经会进入构建容器，此步骤可通跳过。

  a. 确保主机环境python3版本为3.10及其以上，若python3版本不匹配，建议通过conda安装匹配的python3版本环境。

  b. 确认docker已安装，参考网上ubuntu安装docker方法

  c. 安装oebuild最新版本 ( :ref:`abc步骤命令参考 <oebuild_install>` )

  d. 通过oebuild初始化工作目录

  .. code-block:: console

    $ oebuild init [-b SDK配套分支]  [工作目录]
    $ cd [工作目录]
    $ oebuild update

  e. 在对应工作目录，执行容器环境初始化

  .. code-block:: console

    $ oebuild generate -p [平台] [-d DIRECTORY]  
    # -p 为对应平台，与使用的SDK配套，arm64可选qemu-aarch64，x86可选x86-64，或根据单板平台选择
    # PLATFORM开发容器并不区分
    # -d为容器环境的和主机环境即将创建的共享目录

  (1). 进入容器环境

  此时确认您已cd到对应工作目录，即(0)中oebuild generate -d指定的目录，也是您主机和容器的共享目录。

  .. code-block:: console

    $ oebuild bitbake

  oebuild进入开发容器的原理介绍：

  oebuild bitbake命令执行时，会自动检测工作目录下的.env文件，并检查short_id对应的容器id是否存在。
  
  如果不存在就新建一个容器并生成.env文件和short_id，建立容器时，会将当前所处的工作目录（主机），挂载到容器的对应目录。

  如需了解具体过程，可参考 :ref:`oebuild bitbake功能介绍 <command_index_bitbake>`

  除此之外，进入容器后，oebuild bitbake会自动配置一些构建工具的环境建立，如nativesdk等，其中ROS SDK所依赖的主机pyhton3工具就来源于nativesdk。


  (2). 安装1中生成的SDK的sh安装脚本

  假设SDK脚本位于目录“/home/openeuler/build/raspberrypi4-64/output/20230523023324”

  .. code-block:: console

    $ cd /home/openeuler/build/raspberrypi4-64/output/20230523023324
    $ ./openeuler-glibc-x86_64-openeuler-image-ros-cortexa72-raspberrypi4-64-toolchain-23.03.sh
    # 输入安装目录，假设为“/home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk”，目录请事先创建好，按“y”确认
    $ /home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk
    $ y

  (3). 根据提示执行SDK初始化

  后续再次进入容器环境后，只需要初始化即可，不需要（2）安装步骤，用法和我们常规SDK的使用无区别。
  
  .. code-block:: console

    $ . /home/openeuler/build/raspberrypi4-64/output/20230523023324/sdk/environment-setup-cortexa72-openeuler-linux

  可以看到，此步骤将自动初始化交叉编译的依赖，如colcon等工具。
  
  此外，除了初始化上述SDK的环境变量，您无需额外source ros.setup等ROS工作空间，在SDK内部，我们已经准备好了，而SDK提供的colcon，会将colcon命令执行目录自动作为ROS的新增工作空间。


**3. 通过colcon交叉编译ROS包**

  您只需要进入到ros包工程或colcon工程的工作路径，执行colcon进行编译即可，将自动进行交叉编译。

  .. code-block:: console

    $ cd your_rospkg_workspace
    $ colcon build --cmake-args -DBUILD_TESTING=False
    # 注： 这里--cmake-args -DBUILD_TESTING=False 参数是必要项，顾名思义，是为了禁止做不必要的构建时测试，构建时测试需不适用于SDK，且SDK没有集成相关组件。
    
  完成后，和colcon用法一样，在工作目录将生成install文件夹，即交叉编译的目标产物。


**4. 部署和运行（重要）**

  在3中，colcon生成的install可以直接拷贝到目标机器上进行部署运行，但由于colcon固定了工作目录和python解析器，拷贝到新目录后，需要替换一下colcon指定的工作目录和python解析器。

  假设原colcon工作目录为“home/openeuler/build/raspberrypi4-64/your_colcon_workspace/install”，需编辑全部setup.sh文件，将如下内容进行修改：

  .. code-block:: console

    _colcon_prefix_chain_sh_COLCON_CURRENT_PREFIX=/home/openeuler/build/raspberrypi4-64/your_colcon_workspace/install

  部署到目标环境后，假设新工作目录为“/ros_runtime/install”，则需将setup.sh文件的对应行修改为如下内容：

  .. code-block:: console

    _colcon_prefix_chain_sh_COLCON_CURRENT_PREFIX=/ros_runtime/install

  而构建时python解析器是nativesdk提供的，构建时解析器有部分py配置没有及时修正，在目标环境运行时将报错，需要进行修改：

  .. code-block:: console

    _colcon_python_executable="/opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/usr/bin/python3"

  【建议】您直接执行如下命令进行批量修改（后续将集成到colcon或其他工具自动修改）：

  .. code-block:: console

    $ cd /ros_runtime/install
    $ find ./ -type f -exec sed -i 's@/opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/usr/bin/python3@/usr/bin/python3@g' {} +
    # 下述命令需按实际目录填写修改
    $ find ./ -type f -exec sed -i 's@/home/openeuler/build/raspberrypi4-64/your_colcon_workspace/install@/ros_runtime/install@g' {} +

  最后通过如下命令进行工作目录的初始化：

  .. code-block:: console

    $ cd /ros_runtime/install
    $ source /etc/profile.d/ros/setup.bash # 初始化ROS工作目录
    $ source setup.sh # 将当前目录，加入到ROS的额外工作目录


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


