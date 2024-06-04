.. _qemu_start:

QEMU使用
########

本文档主要介绍如何通过qemu运行openEuler Embedded，以及如何使能网络，如何共享宿主机的文件。下面以arm64为例，其它架构与之类似。

1. 安装QEMU
===========

   方法一：通过以下命令安装QEMU

     .. tabs::

        .. tab:: openEuler

           $ sudo yum install qemu-system-aarch64

        .. tab:: Ubuntu

           $ sudo apt-get install qemu-system-arm

        .. tab:: SUSELeap15.4

           $ sudo zepper install qemu-arm

   方法二：基于openEuler社区 `QEMU <https://gitee.com/openeuler/qemu/tree/stable-5.0/>`_ 代码自行编译

     1. 首先下载对应的代码并切换到stable-5.0分支：

     .. code-block:: console

        $ git clone https://gitee.com/openeuler/qemu.git qemu
        $ cd qemu
        $ git checkout -b stable-5.0 remotes/origin/stable-5.0

     2. 编译生成对应的二进制：

     .. code-block:: console

        $ ./configure --target-list=arm-softmmu,aarch64-softmmu --disable-werror
        $ make -j 8
        $ make install #调试不需要

     编译完成后会生成 ``arm-softmmu/qemu-system-arm``、``aarch64-softmmu/qemu-system-aarch64`` 两个文件。

     .. note::

        - | configure 执行过程中，可能会有诸如 ``glib-2.48 gthread-2.0 is required to compile QEMU`` 的失败打印，请按照提示自行安装升级对应的软件包。

        - | configure 时可以通过不同的参数来 ``enable/disable`` 一些 QEMU 的特性或编译选项，如示例中增加的 ``--disable-werror`` 可以允许编译 warning；
          | 如想要体验 openEuler Embedded 共享文件系统场景，需要在 configure 时增加 ``--enable-virtfs`` 来使能对应功能。

2. 获取openEuler Embedded镜像
=============================

   参照 :ref:`快速上手<getting_started>` 部分，使用 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_ 项目构建 ARM64 QEMU 镜像，或者在 `dailybuild <http://121.36.84.172/dailybuild/openEuler-Mainline/>`_ 下载镜像。

3. 使用QEMU运行镜像
===================

   一个简单的qemu执行命令如下：

   .. code-block:: console

      $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
          -kernel zImage \
          -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz

   执行之后等待OS加载完成，很快就能看到登陆提示：

   .. code-block:: console

      Authorized uses only. All activity may be monitored and reported.
      qemu-aarch64 login:

   这意味您已经成功在机器上启动了openEuler Embedded的系统，但此时无法配置网络，也无法通过共享文件系统的方式访问宿主机的文件，接下来会分别介绍如何使能网络和共享文件系统。

.. _qemu_enable_net:

4. 使能网络场景
===============

.. _qemu_local_network:

使能本地网络
----------------

   通过 QEMU 的 ``virtio-net`` 和宿主机上的虚拟网卡，可以实现宿主机和 openEuler Embedded 之间的网络通信，之后可以通过 ``scp`` 实现宿主机和 openEuler Embedded 传输文件。

   **Step1：宿主上建立虚拟网卡**

     在宿主机上需要建立名为tap0的虚拟网卡，可以借助脚本实现，创建 :file:`/etc/qemu-ifup` 脚本，具体内容如下：

     .. tabs::

        .. code-tab:: shell Ubuntu

           #!/bin/bash
           ifconfig $1 192.168.10.1 up

        .. code-tab:: shell SUSELeap15.4

           #!/bin/bash
           ip tuntap add dev "$1" mode tap
           ip link set dev "$1" up
           ip addr add 192.168.10.1/24 dev "$1"

     其执行需要root权限：

     .. code-block:: console

        $ chmod a+x /etc/qemu-ifup

     通过 :file:`qemu-ifup` 脚本，宿主机上将创建名为tap0的虚拟网卡，地址为 ``192.168.10.1``。

   **Step2：启动QEMU时添加netdev**

     针对aarch64(ARM Cortex A57)，运行如下命令：

     .. code-block:: console

        $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
           -kernel zImage \
           -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz \
           -device virtio-net-device,netdev=tap0 \
           -netdev tap,id=tap0,script=/etc/qemu-ifup
      
     .. note::
        如果宿主机是Ubuntu，则运行上述命令可能会出现could not configure /dev/net/tun: Operation not permitted\
        的错误。此时，用户需要sudo权限执行上述命令，才能正常运行。

   **Step3：配置openEuler Embedded网卡**

     openEuler Embedded登陆后，默认会为 eth0 配置地址 ``192.168.10.8``：

     .. code-block:: console

        qemu-aarch64 ~ # ifconfig
        eth0      ... ...
                  inet addr:192.168.10.8  Bcast:0.0.0.0  Mask:255.255.255.0

     也可以通过 ``ifconfig`` 手动配置新的地址，如：

     .. code-block:: console

        $ ifconfig eth0 192.168.10.2

   **Step4：确认网络连通**

     在openEuler Embedded中，执行如下命令：

     .. code-block:: console

        $ ping 192.168.10.1

     如能ping通，则宿主机和openEuler Embedded之间的网络是连通的。

.. _qemu_internet_nat:

使能互联网
--------------

如果宿主机可以与互联网连接，则可以通过NAT模式，与互联网连接。
   
   **Step1：在宿主机添加新的网桥**

   NAT模式的网络包转发的流程如下：

   .. code-block:: console

      # 出栈
      虚拟机网卡（eth0）-> 虚拟机网卡（vnet0）->网桥（br）---- iptable forward -----宿主机网卡（enp1s0）->发出
      # 入栈
      虚拟机网卡（eth0）<- 虚拟机网卡（vnet0）<-网桥（br）---- iptable forward -----宿主机网卡（enp1s0）<-收到
   
   因此，首先需要在宿主机上添加一个新的网桥，如下：

   .. code-block:: console

      # 新增一个网桥
      $ brctl addbr br_qemu
      # 网桥作为QEMU中openEuler Embedded的网关，需要配置IP地址
      $ ifconfig br_qemu 192.168.122.1/24
      # 启动网桥
      $ ifconfig br_qemu up
      # 将ip forward功能打开
      $ echo 1 >> /proc/sys/net/ipv4/ip_forward 

   其中，网桥名称 ``br_qemu`` 可以被更改，IP地址可以更换为任意的未被占用的局域网地址。
   
   **Step2：配置iptables**

   在宿主机中，执行如下命令：

   .. code-block:: console

      $ iptables -A FORWARD -i br_qemu -o enp1s0 -j ACCEPT
      $ iptables -A FORWARD -o br_qemu -i enp1s0 -j ACCEPT
      $ iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j MASQUERADE # NAT地址转换

   其中，enp1s0为宿主机的网卡名称，需要根据实际情况进行修改。

   **Step3：启动QEMU时添加netdev**

   以aarch64(ARM Cortex A53)为例，运行如下命令：

   .. code-block:: console

      $ sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a53 \
         -nographic -smp 4 -kernel zImage -dtb qemu_mcs.dtb \
         -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
         -initrd rootfs.cpio.gz -nographic 

   其中， ``-netdev`` 选项中 ``br`` 参数为宿主机上新建的网桥名称。
   ``-device`` 选项中 ``netdev`` 参数为 ``-netdev`` 指定的 ``id``，
   指定了设备应该连接到的后端。

   **Step4：配置openEuler Embedded网卡**

   openEuler Embedded登陆后，用 ``ifconfig`` 查看网卡名称，如 ``eth0`` 。
   执行如下命令配置网卡的IP地址和ip route的默认网关：

   .. code-block:: console

      $ ifconfig enp0s1 192.168.122.11 netmask 255.255.255.0
      $ ip route add default via 192.168.122.1 dev enp0s1
   
   其中，192.168.122.11可以更改为任意的未被占用的局域网地址。但是，需要保证与宿主机的网桥在同一个网段。
   ``ip route`` 添加默认网关的作用是，当openEuler Embedded需要访问互联网时，将数据包转发到宿主机的网桥上，再由宿主机的网桥转发到互联网。

   **Step5：配置DNS**

   在openEuler Embedded中，执行如下命令：

   .. code-block:: console

      # 修改DNS配置文件
      $ vi /etc/resolv.conf
      # 添加DNS服务器地址
      $ nameserver 1.2.3.4

   **Step6：确认网络连通**

   在openEuler Embedded中，执行如下命令：

   .. code-block:: console

      $ ping www.baidu.com
   
   如能ping通，则说明openEuler Embedded可以访问互联网。

5. 使能共享文件系统场景
=======================

   通过共享文件系统，可以使得运行 QEMU 仿真器的宿主机和 openEuler Embedded 共享文件，这样在宿主机上交叉编译的程序，拷贝到共享目录中，即可在 openEuler Embedded 上运行。注意 QEMU 必须支持 virtfs，即配置了 ``--enable-virtfs``。

   假设将宿主机的 ``/tmp`` 目录作为共享目录，并事先在其中创建了名为 :file:`hello_openeuler.txt` 的文件，使能共享文件系统功能的操作指导如下：

   **Step1：启动QEMU时添加fsdev**

     针对aarch64(ARM Cortex A57)，运行如下命令：

     .. code-block:: console

        $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
            -kernel zImage \
            -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz \
            -device virtio-9p-device,fsdev=fs1,mount_tag=host \
            -fsdev local,security_model=passthrough,id=fs1,path=/tmp

   **Step2：映射文件系统**

     在 openEuler Embedded 启动并登录之后，需要运行如下命令，映射(mount)共享文件系统：

     .. code-block:: console

        $ cd /tmp
        $ mkdir host
        $ mount -t 9p -o trans=virtio,version=9p2000.L host /tmp/host

     即把共享文件系统映射到 openEuler Embedded 的 ``/tmp/host`` 目录下。

   **Step3：检查共享是否成功**

     在openEuler Embedded中，执行如下命令：

     .. code-block:: console

        $ ls /tmp/host

     如能发现hello_openeuler.txt，则共享成功。

6. 使能运行虚拟磁盘场景
=======================

   **Step1：创建虚拟磁盘**

      要实现在openEuler Embedded中共享文件，使用共享文件系统是一个不错的方法。然而，qemu启动命令是将系统加载到内存，在某些应用场景下需要频繁启动openEuler Embedded，每次都需要重新设置共享文件夹，这样操作就显得繁琐。为了解决这个问题，可以考虑构建虚拟磁盘，以实现之前的设置永久保留。下面以SUSE Leap 15.4为例，介绍构建虚拟磁盘的过程：

      .. code-block:: shell

         # 创建1G虚拟磁盘
         $ dd if=/dev/zero of=virtual_disk.img bs=1M count=1024

         # 利用fdisk分区
         $ sudo fdisk virtual_disk.img

         # 将虚拟磁盘挂载
         $ sudo losetup -Pf --show virtual_disk.img

         # 格式化文件系统，可以通过ls /dev查看虚拟磁盘具体挂载在哪
         $ sudo mkfs.ext4 /dev/loop0p1

         # 挂载虚拟磁盘
         $ sudo mkdir /mnt/my_mount_point
         $ sudo mount /dev/loop0p1 /mnt/my_mount_point

   **Step2：复制根文件系统**

      将 ``openeuler-image-qemu-aarch64-*.rootfs.cpio.gz`` 解压，随后拷贝到 ``/mnt/my_mount_point`` 目录下：

      .. code-block:: shell

         # 在openeuler-image-qemu-aarch64-*.rootfs.cpio.gz所在目录下创建temp目录并复制
         $ mkdir temp
         $ cp openeuler-image-qemu-aarch64-*.rootfs.cpio.gz temp && cd temp

         # 解压根文件系统压缩包
         $ gunzip -c openeuler-image-qemu-aarch64-*.rootfs.cpio.gz | cpio -idmv
         $ sudo cp -r * /mnt/my_mount_point

      现在，已成功创建一个包含openEuler Embedded系统的虚拟磁盘。通过qemu你可以运行这个虚拟磁盘中的系统，并且不需要每次登录时都重新设置密码，设置的共享文件夹也会被保留。

   **Step3：启动虚拟磁盘**

      以下是用于启动虚拟磁盘的qemu命令。为了避免每次都输入冗长的命令，你可以在 ``bashrc`` 文件中设置一个alias命令来实现快速启动。

      .. code-block:: console

         $ sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a57 \
            -append 'maxcpus=3 root=/dev/vda1 rootfstype=ext4 rw' \
            -smp 4 -kernel zImage -dtb qemu_mcs.dtb -device virtio-net-device,netdev=tap0 \
            -netdev tap,id=tap0,script=/etc/qemu-ifup \
            -drive file=virtual_disk.img,format=raw -nographic"

      | 其中启动虚拟盘的关键参数如下：
      | ``root=/dev/vda1`` ：指定了根文件系统的位置在挂载的虚拟磁盘的第一块分区上
      | ``-drive file=virtual_disk.img,format=raw`` ：添加一个虚拟磁盘作为虚拟机的存储，虚拟磁盘文件为virtual_disk.img。
      | ``-netdev tap,id=tap0,script=/etc/qemu-ifup`` ： 配置网络设备tap0，并指定用于管理该设备的脚本为/etc/qemu-ifup。

   **Step4：设置SSH密钥**

      尽管虚拟磁盘保存了密码，避免了每次登录时的密码设置，但在实际的调试过程中，通常需要频繁使用scp传输文件或者打开多个终端进行SSH连接。这时，为了简化操作，可以通过配置SSH密钥的方式实现无需输入密码的登录：

      .. code-block:: shell

         # 生成密钥对
         $ ssh-keygen

         # 选择一个文件保存公钥位置，回车默认保存在/home/<user>/.ssh目录下
         $ Enter file in which to save the key (/home/<user>/.ssh/id_rsa):

         # 设置密钥短语，用于保护私钥，回车即可
         $ Enter passphrase (empty for no passphrase):

         # 再次输入密钥短语，回车即可
         $ Enter same passphrase again:

      如果你看到类似以下的输出，表示SSH密钥已成功生成并配置完毕：

      .. code-block:: console

         Your identification has been saved in /home/<user>/.ssh/id_rsa
         Your public key has been saved in /home/<user>/.ssh/id_rsa.pub
         The key fingerprint is:
         SHA256:rOt1tPXpLY9nPiI4ASV/DLHV+5LG/9JBb96jhQu9fPU <user>@localhost.localdomain
         The key's randomart image is:
         +---[RSA 3072]----+
         |         ....    |
         |       . oo  .   |
         |        +.o   .  |
         |       o . o . . |
         |        S o o + .|
         |       . o o.*.++|
         |      . . =..o===|
         |       o + .oo*BE|
         |     .o   . .=*BO|
         +----[SHA256]-----+

      现在，你只需将 ``/home/<user>/.ssh/id_rsa.pub`` 文件的内容追加到虚拟磁盘中的 ``/root/.ssh/authorized_keys`` 文件中即可完成配置。这样，你的SSH密钥将被添加到虚拟机的授权密钥列表中，从而实现免密码的SSH登录。

      .. code-block:: shell

         #将宿主机中的公钥输出，并复制
         $ cat ~/.ssh/id_rsa.pub

         #在qemu中创建目录，并复制内容
         $ mkdir /root/.ssh

         # 粘贴内容保存退出
         $ vi authorized_keys

   设置完成之后，宿主机和openEuler Embedded即可免密通信。

附录：QEMU常用的启动参数
========================

   以下是一些常用的QEMU启动参数：

   - **-M virt**: 指定需要使用的machine类型，virt是qemu提供的一个通用machine，可以同时支持arm32和arm64（部分cortex不支持）， ``-M help`` 可以列出所有支持的machine列表
   - **-m 1G**: 可选，可以通过修改此参数来增大OS的可用内存
   - **-cpu cortex-a57**: 指定模拟的cpu类型，指定 ``-M`` 的情况下可以使用 ``-cpu help`` 查看当前machine支持的cpu类型
   - **-smp 2**: 可选，可以修改OS的cpu数量，默认为1
   - **-append**: 可选，指定内核的启动参数(cmdline)
   - **-kernel**、**-initrd**: 分别用于指定OS的内核和文件系统
   - **-dtb**: 可选，用于指定dtb(device tree)文件
   - **-d in_asm -D qemu.log**: 可选，输出qemu在tcg模式下的"指令流"。 ``-d`` 选择指令流类型，可以用 ``-d help`` 查看支持的选项列表； ``-D`` 指定输出的文件名
   - **-s -S**: 可选，调试参数。 ``-S`` 可以让qemu加载OS的zImage、initrd到指定位置后停止运行，等待gdb连接； ``-s`` 等价于 ``--gdb tcp::1234`` ，启动gdb server并默认监听1234端口
   - **-serial**: 可选，用于串口重定向。不指定时默认为 ``-serial stdio`` ，即打印到标准输入输出。也可以重定向到tcp: ``-serial tcp::1111,server,nowait`` ，通过 ``telnet localhost 1111`` 连接
