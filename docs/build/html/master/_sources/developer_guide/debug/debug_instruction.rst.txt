.. _debug_instruction:

调试指南
#####################

主流的调试工具GDB（GNU Debugger）在类Unix系统中提供了很好的程序调试支持。在openEuler Embedded中，\
我们也可以采用GDB进行调试。\
但是由于嵌入式开发板的计算能力较弱，我们尽量希望减轻嵌入式开发板的工作负担，因此我们选择使用GDB Server，将\
调试器与被调试程序分离开，利用本地机器的算力运行GDB，分担调试时的计算压力。本文将以\
运行在QEMU中的镜像为例，讲解如何调试镜像中的程序。



1. 使能网络

  要想使用GDB Server进行调试，一个重要的前提条件就是能够通过网络访问到openEuler Embbed镜像。\
  我们应该在启动QEMU时为它配置好网络。网络配置不需要特别复杂，配置一个简单的本地网络，使得宿主机\
  能与虚拟机正常通信即可。（参见 `QEMU使能网络场景 \
  <https://embedded.pages.openeuler.org/master/develop_help/qemu/qemu_start.html#id4>`_）\
  
  配置好了网络以后，在镜像中运行 ``ifconfig``，默认的IP地址是 ``192.168.10.8``。

2. 确认GDB Server已经安装

  我们需要先确定镜像中存在GDB Server。运行命令： ``gdbserver --version``，如果返回了版本号（如下代码段所示），则证明\
  镜像中存在GDB Server。

  .. code-block:: shell

    $ gdbserver --version
    GNU gdbserver (GDB) 12.1
    Copyright (C) 2022 Free Software Foundation, Inc.
    gdbserver is free software, covered by the GNU General Public License.
    This gdbserver was configured as "aarch64-openeuler-linux"

3. 启动GDB Server

  接下来，我们需要在openEuler Embbed镜像中启动GDB Server并让它开始在某个端口监听，方便GDB连接后调试。\
  
  启动GDB Server和启动GDB一样，一开始可以不需要指定具体被调试的文件是什么，因为GDB的操作逻辑是命令行交互的模式，\
  我们可以在之后的交互中指定具体的调试文件。在运行gdbserver的时候，带上 ``--multi`` 标志，\
  则告诉GDB Server我希望启动的时候不指定具体需要调试的程序，\
  并且只有在交互时显式输入退出命令，才会退出GDB Server。
  
  而既然要求虚拟机里的GDB Server监听宿主机的GDB连接请求，则必须指定一对\
  IP地址和端口，格式为 ``[ip]:[port]``。由于Server肯定是在虚拟机进行监听，所以IP地址肯定是虚拟机当前的IP地址\
  ``192.168.10.8``，或者写为 ``localhost``。由于IP地址是固定的，当前GDB Server支持IP地址这一部分也可以省略不写。\
  ``:`` 后面的部分是端口，而端口并不可以随意指定，因为在Linux中，保留的端口范围是从0到1023。\
  我们可以占用一个在保留端口范围以外的并且未被使用的端口进行监听，\
  等待GDB的连接请求。下方示例中GDB Server会在本机1234端口等待远程GDB的连接请求。
  
  .. code-block:: shell

    $ gdbserver --multi localhost:1234
    Listening on port 1234

  .. note:: 

    建议在指定IP地址时使用 ``localhost`` 或者直接省略不写。因为如果手写IP地址，即使此IP地址并非是本机当前的IP地址，\
    GDB Server也不会报错，而是简单的将IP地址和端口放入一个套接字，然后开始监听。这个时候，即使GDB Server打印出来\
    正在某端口监听的语句，由于IP地址是错误的，远程GDB永远无法正确的连接当前的GDB Server进行调试。

4. 宿主机中使用GDB连接虚拟机中的GDB server

  要利用宿主机GDB连接虚拟机的GDB Server，首先我们应该运行命令 ``gdb`` 启动GDB调试器。\
  成功启动GDB后就会进入GDB的命令行交互界面，命令行开头会显示 ``(gdb)``。但是，此时GDB仅仅只能调试宿主机的代码。如果我们\
  想连接虚拟机里的GDB Server进行调试，我们需要知道虚拟机的GDB Server正在监听的IP地址和端口号。\
  使用上述方式配置网络并且启动GDB Server后，\
  远程IP地址为 ``192.168.10.8``，端口为 ``1234``。所以，我们用于建立连接的命令如下：

  .. code-block:: shell

    (gdb) target extended-remote 192.168.10.8:1234
    Remote debugging using 192.168.10.8:1234

  连接成功后，GDB会显示如上代码段的内容，表示当前正在通过 ``192.168.10.8:1234`` 远程调试。这表明\
  TCP连接建立成功，之后可以在宿主机上对虚拟机中的代码进行调试。

  .. note:: 

    GDB连接远程GDB Server有两种命令： ``target remote [ip]:[port]`` 和 ``target extended-remote [ip]:[port]``。\
    如果只使用 ``target remote`` 命令，当用户退出debug的程序时，GDB Server会停止工作，GDB也会与远端的GDB Server断开连接。\
    由于我们启动GDB Server时没有具体指定需要debug的程序，如果在宿主机中使用 ``target remote`` 命令连接GDB Server，\
    则远端的GDB Server会马上退出，它和宿主机GDB之间的TCP连接也会马上断开。\
    ``target extended-remote`` 命令则可以避免这个问题，因为即使被调试的程序退出，GDB和GDB Server之间的连接依然会被保持。\
    所以在本文的演示中，使用的是 ``target extended-remote`` 命令连接GDB Server。

5. 编译含有调试信息的可执行文件

  在编译的时候，需要加上 ``-g`` 这一标志，让编译器在编译的时候生成带有调试信息的可执行文件。如果没加上 ``-g`` 这一标志，\
  我们仍然可以使用GDB对可执行文件进行编译，但是由于没有相应的调试信息，我们无法跟踪高级语言中的变量，而只能在汇编语言的层面\
  对可执行文件进行调试。

6. 加载需要被调试的可执行文件

7. 设置断点

8. 开始调试

9. 退出调试