.. _mica_debug:

调试支持 GDB stub 的 Client OS
##############################################################

当前仅支持调试运行在树莓派4B（aarch64）和x86工控机（x86_64）的Uniproton。

基于树莓派4B调测Uniproton
============================================

树莓派4B的具体介绍 :ref:`树莓派4B <board_raspberrypi4b>` 。

树莓派的openeuler-image-mcs构建，参见 :ref:`树莓派mcs镜像构建指导 <raspberrypi4-uefi-guide>`。
由于需要调试，需要在oebuild构建目录中的conf文件夹下的local.conf文件中添加如下配置：

.. code-block:: shell

    # Enable Debugging Features, like including gdb binary in the image
    IMAGE_FEATURE += "debug-tweaks"

当然，也可以在openeuler-image-mcs.bb文件中临时增加上述配置。

编译好了树莓派的openeuler-image-mcs镜像并烧录到sd卡，在树莓派上启动后，配置好UEFI，之后进入系统。

此时，输入如下命令，查看当前系统中支持的RTOS：

.. code-block:: shell

    $ mica status
    Name                          Assigned CPU        State               Service
    uniproton                     3                   Offline
    uniproton-gdb                 3                   Offline

其中，uniproton-gdb是支持GDB stub的Uniproton。它的conf文件的路径为
``/etc/mica/rpi4-uniproton-gdb.conf`` 。这里，有一个很重要的配置选项 ``Debug=yes`` ，
表示此实例支持GDB stub。

输入如下命令启动支持GDB stub的Uniproton：

.. code-block:: shell

    $ mica start uniproton-gdb
    starting uniproton-gdb...
    start uniproton-gdb successfully!

此时，可以通过启动GDB Client连接到MICA GDB server，以调测Uniproton内核：

.. code-block:: shell

    $ mica gdb uniproton-gdb
    gdb /root/raspi4.elf -ex 'target extended-remote :5678' -ex 'set remote run-packet off' -ex 'set remotetimeout unlimited'
    GNU gdb (GDB) 14.1
    Copyright (C) 2023 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    Type "show copying" and "show warranty" for details.
    This GDB was configured as "aarch64-openeuler-linux".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <https://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
        <http://www.gnu.org/software/gdb/documentation/>.

    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from /root/raspi4.elf...
    Remote debugging using :5678
    warning: Remote gdbserver does not support determining executable automatically.
    RHEL <=6.8 and <=7.2 versions of gdbserver do not support such automatic executable detection.
    The following versions of gdbserver support it:
    - Upstream version of gdbserver (unsupported) 7.10 or later
    - Red Hat Developer Toolset (DTS) version of gdbserver from DTS 4.0 or later (only on x86_64)
    - RHEL-7.3 versions of gdbserver (on any architecture)
    0x000000007b025eb4 in OsGdbArchInit ()
    Support for the 'vRun' packet on the current remote target is set to "off".
    (gdb)

第一行打印的gdb命令是输入 ``mica gdb <name>`` 后所实际执行的gdb命令，
用户可以依据此提示进一步调试。之后，用户进入GDB命令行，可以执行相应的GDB命令。
接下来会演示一些当前Uniproton支持的调测命令：

.. code-block:: shell

    (gdb) b OsTestInit
    warning: could not convert 'OsTestInit' from the host encoding (ANSI_X3.4-1968) to UTF-32.
    This normally should not happen, please file a bug report.
    Breakpoint 1 at 0x7b007b4c: file /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c, line 42.
    (gdb) c
    Continuing.

    Breakpoint 1, OsTestInit () at /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c:42
    warning: 42     /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c: No such file or directory
    (gdb) s
    43      in /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c
    (gdb) p param
    $1 = {taskEntry = 0x0, taskPrio = 0, reserved = 0, args = {0, 0, 0, 2063689196}, 
    stackSize = 2063629368, 
    name = 0x2307b01dd48 <error: Cannot access memory at address 0x2307b01dd48>, stackAddr = 2064460304}
    (gdb) s
    45      in /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c
    (gdb) p param
    $2 = {taskEntry = 0x0, taskPrio = 0, reserved = 0, args = {0, 0, 0, 0}, stackSize = 0, name = 0x0, 
    stackAddr = 0}
    (gdb) watch param.taskPrio
    Hardware watchpoint 2: param.taskPrio
    (gdb) c
    Continuing.

    Hardware watchpoint 2: param.taskPrio

    Old value = 0
    New value = 25
    OsTestInit () at /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c:48
    48      in /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c
    (gdb) c
    Continuing.

    Watchpoint 2 deleted because the program has left the block in
    which its expression is valid.
    0x000000007b007c54 in PRT_AppInit ()
        at /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c:86
    86      in /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c
    (gdb) c
    Continuing.
    ^C
    Program received signal SIGINT, Interrupt.
    0x000000007b01da84 in PRT_SemPend ()
    (gdb) run
    The program being debugged has been started already.
    Start it from the beginning? (y or n) y
    Starting program: /root/raspi4.elf 
    warning: Remote gdbserver does not support determining executable automatically.
    RHEL <=6.8 and <=7.2 versions of gdbserver do not support such automatic executable detection.
    The following versions of gdbserver support it:
    - Upstream version of gdbserver (unsupported) 7.10 or later
    - Red Hat Developer Toolset (DTS) version of gdbserver from DTS 4.0 or later (only on x86_64)
    - RHEL-7.3 versions of gdbserver (on any architecture)
    
    Breakpoint 1, OsTestInit () at /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c:42
    warning: 42     /home/zzz/repo/private/UniProton/demos/raspi4/apps/openamp/main.c: No such file or directory
    (gdb)

1. 首先，通过 ``break`` 命令在 ``OsTestInit`` 函数处设置断点，之后通过 ``continue`` 命令继续执行。
2. 在 ``OsTestInit`` 函数处，通过 ``print`` 命令查看 ``param`` 结构体的内容，之后通过 ``step`` 命令逐行执行。
3. 在 ``param.taskPrio`` 变量处，通过 ``watch`` 命令设置硬件监视点，之后通过 ``continue`` 命令继续执行。
4. 在 ``param.taskPrio`` 变量发生变化时，GDB会停止执行。当代码执行的区域超出了 ``param.taskPrio`` 变量所处的区域，GDB也会停止执行。
5. 通过执行 ``continue``，RTOS持续运行了起来。 之后可以通过 ``ctrl-c`` 命令停止执行。
6. 之后，可以通过 ``run`` 命令重新加载并启动RTOS，Uniproton会在第一个断点处停止执行。

输入 ``quit`` 命令退出GDB调试模式，之后，Uniproton会清除所有断点，并进入正常的运行状态。
之后，如果想停止Uniproton，可以输入如下命令：

.. code-block:: shell

    $ mica stop uniproton-gdb
    stopping uniproton-gdb...
    stop uniproton-gdb successfully!

.. note::

    由于Uniproton在GDB stub方面的具体实现方式，如果Uniproton正在等待GDB client的连接，
    它还没有初始化中断，所以在这个阶段，Uniproton不会响应系统停止的指令。
    因此，此时发送 ``mica stop <name>`` 命令是无效的。

基于x86工控机调测Uniproton
============================================

工控机的具体介绍 :ref:`工控机 <hvaepic-m10>` 。

相关接口定义
-------------

首先，对于Client OS而言，需要支持GDB stub。
当前MICA框架仅支持基于简单ring buffer通信的方式进行GDB stub信息的交互，
ring buffer的地址和大小在MCS仓库中 ``library/include/mcs/mica_debug_ring_buffer.h`` 中定义：

.. code-block:: c

   // x86 ring buffer base address offset and size
   #define RING_BUFFER_SHIFT 0x4000
   #define RING_BUFFER_SIZE 0x1000

x86架构下由于ring buffer存在的物理空间的首地址始终相对于Uniproton的入口地址是固定的，
在做内存映射的时候我们ring buffer的首地址可以通过Uniproton的入口地址减去 ``RING_BUFFER_SHIFT`` 得到。

ring buffer 的定义在 ``library/include/mcs/ring_buffer.h`` 文件中。

使用方法
----------

首先，需要构建含有MICA的openEuler Embedded镜像，请参考 :ref:`MICA镜像构建指南 <mcs_build>` 。

然后，需要生成适配了GDB stub 的 Uniproton，参考 `UniProton GDB stub 构建指南 <https://gitee.com/openeuler/UniProton/blob/master/doc/gdbstub.md>`_ 。

在运行命令时，需要在启动MICA时加上 ``-d`` 参数。
并且，由于需要对可执行文件进行调试， ``-t`` 参数需要指定包含符号表的可执行文件的路径。
一般来说，plain binary format的可执行文件并没有相关调试信息，
所以我们只能使用elf格式的可执行文件进行调试。
当然，如果 ``-t`` 参数指定的是格式为plain binary format的可执行文件的路径，
调试模式仍然可以正常启动，但是在启动GDB client的时候无法正确读取符号表，
需要用 ``file`` 命令额外指定包含符号表的可执行文件的路径。

以下是启动MICA调试模式的命令：

.. code-block:: console

   # 若使用的是标准镜像，则使用mica脚本启动MICA：
   $ mica start /path/to/executable -d
   # 若没有mica脚本，则使用如下命令启动MICA：
   $ insmod /path/to/mcs_km.ko rmem_base=0x118000000 rmem_size=0x10000000
   # 启动MICA调试模式：
   $ /path/to/mica_main -c 3 -t /path/to/executable -a 0x118000000 -b /path/to/ap_boot -d
   ...
   MICA gdb proxy server: starting...
   GNU gdb (GDB) 12.1
   Copyright (C) 2022 Free Software Foundation, Inc.
   License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
   This is free software: you are free to change and redistribute it.
   There is NO WARRANTY, to the extent permitted by law.
   Type "show copying" and "show warranty" for details.
   This GDB was configured as "x86_64-openeuler-linux".
   ...
   MICA gdb proxy server: read for messages forwarding ...
   (gdb)

此时，用户可以直接通过GDB命令行输入命令与Client OS进行交互。
如果用户想要通过GDB命令行像正常情况一样运行client OS，可以直接不设置断点，输入命令 ``continue`` 。

按下 ``ctrl-c`` 之后会返回GDB命令行，此时用户可以输入GDB命令与Client OS进行交互。
如果用户想要退出调试模式，必须在GDB命令行输入 ``quit`` 命令。之后，
MICA会退出与调试相关的模块，并保留pty application模块，以保持和Client OS通过pty交互的能力。
Uniproton会清除所有断点，并进入正常的运行状态。

.. note::

    当前Uniproton的GDB stub支持 ``break``， ``continue``， ``print`` ，
    ``quit`` ， ``backtrace``， ``watch``， ``step``， ``run`` 和 ``ctrl-c`` 九个命令。
