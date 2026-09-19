.. _debug_commands:

调试命令入门指南
#######################################

在 :ref:`准备好基于GDB Server的调试环境 <debug_preparation>` 之后，我们可以使用GDB调试我们的程序。
本文会介绍一些调试时常用的命令，以及如何使用这些命令。

.. note::
  
  接下来的调试命令指南，会以基于OpenAMP的混合部署守护进程 ``micad`` 为例，
  讲解如何使用GDB调试。构建混合部署守护进程的方法请参考 :ref:`MCS构建指导 <mcs_build>`。
  为了能够编译出带有调试信息的 ``micad`` 可执行文件，我们需要在构建 ``micad`` 时，
  在yocto构建工程的 ``bb`` 文件中加上 ``EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Debug"`` 
  这一行。或者如果用户是使用nativesdk工具链编译 ``micad``，
  则需要在使用 ``cmake`` 命令编译 ``micad`` 时，
  加上 ``-DCMAKE_BUILD_TYPE=Debug`` 这一标志。
  
  此外，由于 ``micad`` 是一个守护进程，启动的时候会fork两次，
  直到获得一个既不是session leader也没有控制终端的进程。因此，
  GDB会在第一次fork的时候认为程序已经退出，无法正常调试 ``micad``。
  为了方便，调试micad的时候可以将 ``main`` 函数里的 ``daemonize`` 函数注释掉。

1. 加载需要被调试的可执行文件

  使用 ``file`` 命令可以手动加载可执行文件，从而获取调试信息。
  这个时候，我们需要指定在本地主机上的可执行文件的路径。
  例如，我们加载位于当前目录下的混合部署守护进程 ``micad`` 这一可执行文件，命令如下：

  .. code-block:: shell

    (gdb) file micad
    Reading symbols from micad...

  如果加载成功，GDB会打印出 ``Reading symbols from micad...`` 这一句话。

  当然，对于调试目标机器上的二进制而言，每次都要在本地主机上准备一份同样的二进制文件是一件麻烦的事情，
  因此我们可以在GDB中使用 ``file`` 命令指定远程运行的二进制文件的路径，命令如下：

  .. code-block:: shell

    (gdb) file target:/path/to/micad
    Reading symbols from target:/path/to/micad...
  
  在使用 ``file`` 命令加载远程运行的二进制文件时，``target`` 关键字是必须的，
  后面跟着的是目标机器上的二进制文件的路径。

  只有加载了调试信息后，才能正常的设置断点。否则，GDB无法判断设置的断点是否真实存在。

2. 设置断点

  在GDB中，我们可以使用 ``break`` 命令设置断点。设置断点的格式如下：

  .. code-block:: shell

    (gdb) break [filename:]function_name
    (gdb) break [filename:]line_number
  
  其中 ``filename`` 是组成可执行文件时的众多文件中的其中一个文件，
  ``function_name`` 是函数名， ``line_number`` 是行号。

  例如，我们想在 ``micad`` 的 ``mica_debug.c`` 文件中的 ``debug_start`` 函数设置断点，
  此函数在编写文档时，位于文件的第81行。命令如下：

  .. code-block:: shell

    (gdb) break mica_debug.c:81
    Breakpoint 1 at 0xe520: file ./mica/micad/services/debug/mica_debug.c, line 82.
    (gdb) break mica_debug.c:debug_start
    Breakpoint 2 at 0xe520: file ./mica/micad/services/debug/mica_debug.c, line 82.
  
  既可以使用行号，也可以使用函数名称，都可以成功设置断点。

3. 查看源代码

  二进制的调试信息中，只含有源代码的路径，而不含有源代码本身。GDB会根据源代码的路径，
  在本地文件系统中查找源代码文件。如果GDB找到了源代码文件，我们可以使用 ``list`` 命令查看源代码。
  指定源代码的路径可以使用命令 ``directory``，可以指定绝对或者相对路径。
  比如，当前源代码顶层目录在gdb当前工作目录的 ``./mcs`` 目录下，我们可以使用如下命令：

  .. code-block:: shell

    (gdb) directory mcs
    Source directories searched: /home/yongmao/mcs:$cdir:$cwd

  上述打印说明，GDB除了在当前工作目录和编译目录下搜索源代码外，
  还会在 ``/home/yongmao/mcs`` 目录下搜索源代码。

  GDB查找源代码的路径的逻辑可以参考官方文档： 
  `GDB指定源码路径 <https://www.sourceware.org/gdb/current/onlinedocs/gdb.html/Source-Path.html#Source-Path>`_。
  简单来说，如果二进制的调试信息中包含的源代码路径是绝对路径（/usr/src/foo-1.0/lib/foo.c），
  而搜索路径已定义（/mnt/cross），则GDB会在下列3个路径中查找源代码：
  
  1. 搜索路径的下一层中是否含有源代码文件（/mnt/cross/foo.c）。
  2. 从搜索路径开始，加上完整的“绝对路径”后是否有源代码文件（/mnt/cross/usr/src/foo-1.0/lib/foo.c）。
  3. 绝对路径是否有源代码文件（/usr/src/foo-1.0/lib/foo.c）。

  如果都没有，则认为源代码文件不存在。因此，在编译的时候，我们应该尽量使用相对路径，
  比如当前micad在编译的时候，调试信息中的路径是相对于项目顶层目录的路径。这样，
  我们在GDB中指定源代码路径时，只需要指定项目顶层目录，即可正确的找到源代码。

  此时，我们可以使用 ``list`` 命令查看源代码。比如，查看 ``mica_debug.c`` 文件的第81行：

  .. code-block:: shell

    (gdb) list mica_debug.c:81
    76                      mq_close(g_to_server);
    77
    78              syslog(LOG_INFO, "closed message queue\n");
    79      }
    80
    81      static int debug_start(struct mica_client *client_os, struct mica_service *svc)
    82      {
    83              int ret;
    84
    85              ret = alloc_message_queue();

4. 设置远端运行的二进制文件

  由于我们使用GDB Server进行调试，实际程序运行在目标机器上，
  因此我们需要设置在目标机器上实际运行的二进制的路径，使用如下命令：

  .. code-block:: shell

    (gdb) set remote exec-file /target/path/to/executable

  上述的二进制文件路径是目标机器上的路径，而不是本地主机上的路径。

  如果我们在本地主机上使用 ``file`` 命令加载了远程运行的二进制文件，
  可以不执行这一步，而直接使用 ``run`` 命令启动远端的二进制文件。

  如果使用了 ``file`` 命令加载了本地的二进制，则运行的时候会出错。
  此时必须使用 ``set remote exec-file`` 命令设置远端运行的二进制文件的路径。

  如果没有使用 ``file`` 命令加载远程运行的二进制文件的调试信息，
  手动设置远程运行的二进制文件的路径是必须的。
  否则执行 ``run`` 命令时，如果没有使用 ``file`` 命令，则GDB并不知道要启动什么二进制，
  手动设置远程运行的二进制文件的路径之后，如果之前并没有使用 ``file`` 命令加载调试信息，
  执行 ``run`` 命令时，GDB会自动从远程的二进制文件加载调试信息。

5. 运行程序

  设置好远端运行的程序以后，我们可以使用 ``run`` 命令开始运行程序。

  .. code-block:: shell

    (gdb) run
    'target:/root/micad' has disappeared; keeping its symbols.
    Starting program: target:/root/micad 
    Reading /lib64/ld-linux-aarch64.so.1 from remote target...
    Reading /lib64/ld-linux-aarch64.so.1 from remote target...
    Reading /usr/lib/debug/.build-id/d9/992ac5a89e7f12140d1b1b8f912fc4db734dc9.debug from remote target...
    Reading /usr/lib64/libmetal.so.1 from remote target...
    Reading /usr/lib64/libopen_amp.so.1 from remote target...
    Reading /lib64/libc.so.6 from remote target...
    Reading /lib64/libsysfs.so.2 from remote target...
    Reading /usr/lib/debug/.build-id/15/bf2c762a2e31b7b0c7e7296931f50fc98e74e9.debug from remote target...
    Reading /usr/lib/debug/.build-id/e0/a3fb74de0657e257b3900e6f6f8cff41742d06.debug from remote target...
    Reading /usr/lib/debug/.build-id/48/8ff7719a47eb95444e8c02d2c123a47752f856.debug from remote target...
    [Detaching after fork from child process 558]
  
  micad启动后会注册一个socket listener，监听mica前端发送的命令。
  因此如果没有提前设置断点，则micad会运行到等待前端发送命令的状态，直到socket收到了命令，
  micad的socket listener线程会被唤醒执行对应的任务。
  此时，我们输入 ``mica start [os_name]`` 命令，micad会启动名为 ``os_name`` 的OS。
  如果此OS支持调试，则micad会启动对应的服务，然后走到我们设置的断点 ``mica_debug.c:81``。

6. 逐行执行程序

  .. code-block:: shell

    [New Thread 556.557]
    [New Thread 556.559]
    [Switching to Thread 556.557]

    Thread 2 "micad" hit Breakpoint 1, debug_start (client_os=0x7ff0000e00, svc=0x7ff0001a70) at ./mica/micad/services/debug/mica_debug.c:82
    82      {
    (gdb) s
    85              ret = alloc_message_queue();
    (gdb) n
    37      .-sdk/sysroots/aarch64-openeuler-linux/usr/include/bits/syslog.h: No such file or directory.
    (gdb) list
    32      in .-sdk/sysroots/aarch64-openeuler-linux/usr/include/bits/syslog.h
    (gdb) s
    90              syslog(LOG_INFO, "alloc message queue success\n");
    (gdb) s
    0x000000555555e5b4 in syslog (__fmt=0x55555653a8 "alloc message queue success\n", 
        __pri=6) at .-sdk/sysroots/aarch64-openeuler-linux/usr/include/bits/syslog.h:37
    37      .-sdk/sysroots/aarch64-openeuler-linux/usr/include/bits/syslog.h: No such file or directory.
    (gdb) s
    debug_start (client_os=0x7ff0000e00, svc=<optimized out>) at ./mica/micad/services/debug/mica_debug.c:92
    92              ret = start_ring_buffer_module(client_os, g_from_server, g_to_server, &g_ring_buffer_module_data);
    (gdb) s
    start_ring_buffer_module (client=client@entry=0x7ff0000e00, from_server=13, to_server=14, data_out=data_out@entry=0x5555581028 <g_ring_buffer_module_data>) at ./mica/micad/services/debug/mica_debug_ring_buffer.c:112
    warning: Source file is more recent than executable.
    112     {

  上述代码中，我们可以使用 ``step`` 命令单步执行程序。如果遇到函数调用，
  我们可以使用 ``step`` 命令进入函数内部，再一步步的执行函数内部的代码。
  如果希望直接执行整个函数，而不是仔细的执行函数内的每一行代码，使用 ``next`` 命令。

7. 打印变量的值

  我们还可以使用 ``print`` 命令打印变量的值。有的时候，会发现GDB提示 ``<optimized out>``，
  这是因为编译器优化的原因，GDB无法获取到变量的值。
  我们可以通过 ``p data->len`` 命令发现，当执行到赋值语句下一行时，变量的值才会被赋值。

  .. code-block:: shell

    (gdb) s
    114             struct debug_ring_buffer_module_data *data = (struct debug_ring_buffer_module_data *)calloc(1, sizeof(struct debug_ring_buffer_module_data));
    (gdb) p data
    $2 = <optimized out>
    (gdb) s
    123             ret = transfer_data_to_rtos(data);
    (gdb) p data
    $3 = <optimized out>
    (gdb) n
    117             data->len = rbuf_dev->rbuf_len;
    (gdb) p data
    $4 = (struct debug_ring_buffer_module_data *) 0x7ff0001fa0
    (gdb) p data->len
    $5 = 0
    (gdb) s
    123             ret = transfer_data_to_rtos(data);
    (gdb) p data->len
    $6 = 4096

8. 查看调用栈

  我们可以通过 ``backtrace`` 命令查看当前的调用栈。调用栈是一个函数调用的历史记录，
  描述了函数是如何被调用的。调用栈的最顶部是当前正在执行的函数，最底部是程序的入口函数。

  .. code-block:: shell

    (gdb) bt
    #0  start_ring_buffer_module (client=client@entry=0x7ff0000e00, from_server=13, 
        to_server=14, data_out=data_out@entry=0x5555581028 <g_ring_buffer_module_data>)
        at ./mica/micad/services/debug/mica_debug_ring_buffer.c:123
    #1  0x000000555555e5d8 in debug_start (client_os=0x7ff0000e00, svc=<optimized out>)
        at ./mica/micad/services/debug/mica_debug.c:92
    #2  0x000000555555ffdc in mica_register_service (client=0x7ff0000e00, 
        svc=svc@entry=0x5555580660 <debug_service>)
        at ./library/rpmsg_device/rpmsg_service.c:55
    #3  0x000000555555e778 in create_debug_service (client=<optimized out>)
        at ./mica/micad/services/debug/mica_debug.c:134
    #4  0x0000005555554f4c in client_ctrl_handler (epoll_fd=3, data=0x7ff0001130)
        at ./mica/micad/socket_listener.c:294
    #5  0x0000005555555510 in wait_create_msg (arg=<optimized out>)
        at ./mica/micad/socket_listener.c:451
    #6  0x0000007ff7e107d8 in ?? () from target:/lib64/libc.so.6
    #7  0x0000007ff7e75f4c in ?? () from target:/lib64/libc.so.6

9. 查看当前线程

  我们可以使用 ``info threads`` 命令查看当前的线程。

  .. code-block:: shell

    (gdb) info threads
      Id   Target Id              Frame 
      1    Thread 556.556 "micad" 0x0000007ff7e0d224 in ?? () from target:/lib64/libc.so.6
    * 2    Thread 556.557 "micad" start_ring_buffer_module (
        client=client@entry=0x7ff0000e00, from_server=13, to_server=14, 
        data_out=data_out@entry=0x5555581028 <g_ring_buffer_module_data>)
        at ./mica/micad/services/debug/mica_debug_ring_buffer.c:123
      3    Thread 556.559 "micad" 0x0000007ff7e6c764 in poll () from target:/lib64/libc.so.6

  上述代码中，我们可以看到当前有3个线程，其中 ``*`` 表示当前正在执行的线程。

10. 切换线程

  此时，我们可能会有疑惑：那么另外两个线程是干什么的呢？无法从表面的名字看出来。
  我们可以使用 ``thread`` 命令切换线程，如：

  .. code-block:: shell

    (gdb) thread 3
    [Switching to thread 3 (Thread 556.559)]
    #0  0x0000007ff7e6c764 in poll () from target:/lib64/libc.so.6
    (gdb) bt
    #0  0x0000007ff7e6c764 in poll () from target:/lib64/libc.so.6
    #1  0x0000005555561764 in poll (__timeout=-1, __nfds=2, __fds=0x7ff754e928)
        at .-sdk/sysroots/aarch64-openeuler-linux/usr/include/bits/poll2.h:39
    #2  rproc_wait_event (arg=<optimized out>) at ./library/remoteproc/baremetal_rproc.c:85
    #3  0x0000007ff7e107d8 in ?? () from target:/lib64/libc.so.6
    #4  0x0000007ff7e75f4c in ?? () from target:/lib64/libc.so.6
  
  切换线程后，我们可以使用 ``backtrace`` 命令查看当前线程的调用栈。
  由调用栈可知，线程3执行到当前的状态的过程中，调用了 ``rproc_wait_event`` 函数，
  这个函数是用来等待rproc通知的，
  也就是当接收到远端OS的中断时，会唤醒这个线程，然后触发指定virtqueue的回调函数。
  由于在这里的virtqueue是属于rpmsg-virtio设备的，
  所以virtqueue的回调函数会触发指定rpmsg endpoint的回调函数。

11. 停止调试

  如果希望停止调试当前进程，可以使用 ``kill`` 命令。之后，GDB会停止调试当前进程，
  并进入命令行交互模式。我们可以选择继续调试其他进程，或者退出GDB。

  当然，我们也可以使用 ``quit`` 命令直接退出GDB。这样，进程会被直接停止。

  .. code-block:: shell

    (gdb) quit
    A debugging session is active.

            Inferior 1 [process 556] will be killed.

    Quit anyway? (y or n) n
    Not confirmed.
    (gdb) kill
    Kill the program being debugged? (y or n) y
    [Inferior 1 (process 556) killed]
    (gdb) quit
  
  上述命令中，我们先使用 ``kill`` 命令退出了远端正在被调试的进程，
  然后使用 ``quit`` 命令退出GDB。由于GDB Server是以multi模式启动的，
  GDB Client退出并不会影响GDB Server的运行状态，而是会一直在目标机器上运行等待下一次连接。
