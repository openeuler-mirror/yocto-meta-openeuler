.. _qemu_start_debug:

qemu使用和调试
##############################

本文档主要用于介绍如何获得qemu的二进制，qemu的运行，以及如何基于qemu进行一些简单的调试。

qemu使用
************************

下面介绍如何在自己的机器上编译并运行一个linux镜像。

获取二进制
========================

获取qemu的二进制可以通过如下方式:

- 基于openEuler社区 `qemu <https://gitee.com/openeuler/qemu/tree/stable-5.0/>`_ 代码自行编译:

  - 首先下载对应的代码并切换到stable-5.0分支:

  .. code-block:: console

      git clone https://gitee.com/openeuler/qemu.git qemu
      cd qemu
      git checkout -b stable-5.0 remotes/origin/stable-5.0

  - 编译生成对应的二进制:

  .. code-block:: console

      ./configure --target-list=arm-softmmu,aarch64-softmmu --disable-werror
      make -j 8
      make install #调试不需要

  编译完成后会生成arm-softmmu/qemu-system-arm、aarch64-softmmu/qemu-system-aarch64两个文件。

 .. note::

      configure执行过程中，可能会有诸如”glib-2.48 gthread-2.0 is required to compile QEMU“的失败打印，请按照提示自行安装升级对应的软件包。

      configure时可以通过不同的参数来enable/disable一些qemu的特性或编译选项，如示例中增加的--disable-werror可以允许编译warning；如想要体验openEuler Embedded共享文件系统场景，需要在configure时增加--enable-virtfs来使能对应功能。

openEuler Embedded镜像
========================

参照 :ref:`快速上手<getting_started>` 部分。

qemu运行
========================

一个简单的qemu执行命令如下：

.. code-block:: console

    qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic -kernel zImage -initrd initrd

执行之后等待OS加载完成，很快就能看到登陆提示：

.. code-block:: console

    Authorized uses only. All activity may be monitored and reported.
    openeuler login:

这也意味你已经成功在机器上启动了openEuler Embedded的系统。

这里也介绍一些常用的qemu启动参数：

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

内核调试
************************

qemu的另一大优势便是可以使用gdb来对内核进行调试，这对于嵌入式开发者来说能极大的提高开发效率。
在原有的开发环境中，如果想调试内核，只能在出问题的代码附近加上printk打印，重编内核，将镜像烧到开发板上查看打印信息，如果出问题的阶段非常早，无法调用printk，还需要手动实现往串口物理地址打印的代码。

而有了gdb之后，可以直接在内核需要调试的位置下断点，查看对应的寄存器和变量的值。

调试准备
========================

除了上面使用部分需要的东西之外，我们还需要一个vmlinux文件，一般在编译linux内核后在内核的根目录下就能找到。可以自行从openEuler社区下载linux的源码并编译生成。另外请确保vmlinux和zImage是由同一份内核源码和同一份内核config生成。

实例
========================

以aarch64为例，介绍如何使用qemu进行内核调试。

.. note::

    调试自解压部分时，需要使用arch/arm64/boot/compressed/vmlinux，并在gdb加载vmlinux时，使用

    .. code-block:: console

      (gdb) add-symbol-file vmlinux 0x40080000

    的方式来加载符号信息，0x40080000对应的地址实际上就是qemu加载zImage的位置，可以在qemu的控制台通过 ``info roms`` 查看


在终端执行如下命令：

.. code-block:: console

    qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic -kernel zImage -initrd initrd "-S -s"

可以发现此时命令行不再继续往下执行，我们另外打开一个窗口，启动gdb并连接qemu：

.. code-block:: console

    gdb
    (gdb) file vmlinux
    (gdb) target remote :1234
    (gdb) b start_kernel
    (gdb) c

上面的 ``target remote :1234`` 用于连接qemu启动的gdb server； ``file vmlinux`` 用于加载符号信息。
在执行完 ``c`` 之后，内核会开始运行，遇到我们在start_kernel下的断点后会再次停止，此时可以通过 ``p / bt`` 等方式查看变量或调用栈。

一些调试内核时常用的gdb命令：

- **p**: 打印通用寄存器或者变量。 ``p $x1`` 或者 ``p command_line``
- **x/32wx addr**: 以16进制，按word(32位)为单位，打印从addr开始的32个值
- **disas [addr]**: 反汇编，可以结合qemu.log和objdump后的vmlinux一起查看
- **n, s / ni, si**: 单步执行，ni,si 针对汇编
- **info registers**: 打印寄存器
- **bt**: 查看调用栈
- **b [addr] [if condition]**: 断点，某些场景下可能需要条件断点来过滤部分（如想查看某个中断是否上报可以在中断入口处增加调试断点，减少非预期的停止）
