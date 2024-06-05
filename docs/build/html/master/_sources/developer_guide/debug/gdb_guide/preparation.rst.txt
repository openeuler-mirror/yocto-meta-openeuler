.. _debug_preparation:

准备好基于GDB Server的调试环境
#################################################

主流的调试工具GDB（GNU Debugger）在类Unix系统中提供了很好的程序调试支持。
在openEuler Embedded中，我们也可以采用GDB进行调试。
但是由于嵌入式开发板的计算能力较弱，我们尽量希望减轻嵌入式开发板的工作负担，
因此我们选择使用GDB Server，将调试器与被调试程序分离开，利用本地机器的算力运行GDB，
分担调试时的计算压力。

1. 确认GDB Server已经安装

  我们需要先确定镜像中存在GDB Server。运行命令： ``gdbserver --version``， \
  如果返回了版本号（如下代码段所示），则证明镜像中存在GDB Server。

  .. code-block:: shell

    $ gdbserver --version
    GNU gdbserver (GDB) 12.1
    Copyright (C) 2022 Free Software Foundation, Inc.
    gdbserver is free software, covered by the GNU General Public License.
    This gdbserver was configured as "aarch64-openeuler-linux"

  如果镜像中没有GDB Server，我们可以在构建openEuler Embedded镜像时，
  加上如下语句：

  .. code-block:: shell

    IMAGE_FEATURES += "debug-tweaks"

  这样，构建出的镜像中就会包含调试相关的工具，包括GDB Server。

  .. note::

    由于 ``debug-tweaks`` 会增加所有与调试相关的特性，如导致镜像没有登录密码，因此在构建镜像时，
    如果不需要其他的调试相关的特性，而是仅仅需要GDB Server，
    可以将 ``packagegroup-core-tools-debug`` 添加到 ``IMAGE_INSTALL`` 中，
    而不需要开启 ``debug-tweaks`` 特性。

2. 使能网络

  要想使用GDB Server进行调试，一个重要的前提条件就是能够通过网络访问到openEuler Embbed镜像。
  如果是调试在QEMU中运行的openEuler Embedded中的程序，我们应该在启动QEMU时为它配置好网络。
  网络配置不需要特别复杂，配置一个简单的本地网络，使得宿主机能与虚拟机正常通信即可。
  （参见 `QEMU使能网络场景 \
  <https://embedded.pages.openeuler.org/master/develop_help/qemu/qemu_start.html#id4>`_）

  如果是调试在开发板中运行的openEuler Embedded中的程序，我们可以使用网口，
  通过以太网连接开发板。以树莓派4B为例，
  当前树莓派4B的openEuler Embedded镜像也默认将IP地址配置为静态地址，
  只需要将树莓派4B的网口与本地主机的网口连接，然后在本地主机中安装好网口驱动，
  并配置网口对应的网卡IP地址与树莓派4B的IP地址在同一个网段即可。
  
  配置好了网络以后，在镜像中运行 ``ifconfig``，默认的IP地址是 ``192.168.10.8``，
  子网掩码是 ``255.255.255.0``。因此，
  我们可以在本地主机中配置以太网卡的IP地址为 ``192.168.10.7`` 。

3. 启动GDB Server

  接下来，我们需要在openEuler Embbed镜像中启动GDB Server并让它开始在某个端口监听，
  方便GDB连接后调试运行在目标机器上的程序。
  
  启动GDB Server和启动GDB一样，一开始可以不需要指定具体被调试的文件是什么，
  我们可以在之后的交互中指定具体的调试文件。
  在运行gdbserver的时候，带上 ``--multi`` 标志，\
  则告诉GDB Server我希望启动的时候能支持调试多个进程，因此可以不指定具体需要调试的程序。
  在交互时显式输入退出命令，只会断开与GDB Server的连接，但是GDB Server不会退出，
  会等待GDB Client下一个连接请求。除非在被调试的机器上直接停止GDB Server，
  否则GDB Server会一直运行。
  
  而既然要求目标机器里的GDB Server监听本地主机的GDB连接请求，则必须指定一对IP地址和端口，
  用于Server监听以及Client连接。定义的格式为 ``[ip]:[port]``。
  由于Server是在目标机器进行监听，所以IP地址肯定是目标机器当前的IP地址，写为 ``localhost``。
  或者，也可以使用目标机器网卡的IP地址，在上述例子中就是 ``192.168.10.8``。
  如果IP地址对于GDB Server来说就是本机的IP地址，那么IP地址这一部分也可以省略不写。
  ``:`` 后面的部分是端口，而端口并不可以随意指定，
  因为在Linux中，保留的端口范围是从0到1023。
  我们可以占用一个在保留端口范围以外的并且未被使用的端口进行监听，
  等待GDB的连接请求。下方示例中GDB Server会在本机1234端口等待远程GDB的连接请求。
  
  .. code-block:: shell

    $ gdbserver --multi localhost:1234
    Listening on port 1234

  .. note:: 

    建议在指定IP地址时使用 ``localhost`` 或者直接省略不写。因为如果手写IP地址，
    即使此IP地址并非是本机当前的IP地址，GDB Server也不会报错，
    而是简单的将IP地址和端口放入一个套接字，然后开始监听。这个时候，
    即使GDB Server打印出来正在某端口监听的语句，由于IP地址是错误的，
    远程GDB永远无法正确的连接当前的GDB Server进行调试。

4. 本地主机中使用GDB连接虚拟机中的GDB server

  要在本地主机使用GDB连接虚拟机的GDB Server，首先我们应该运行命令 ``gdb`` 启动GDB调试器。
  成功启动GDB后就会进入GDB的命令行交互界面，命令行开头会显示 ``(gdb)``。
  但是，此时GDB仅仅只能调试本地主机的代码。如果我们想连接虚拟机里的GDB Server进行调试，
  我们需要知道虚拟机的GDB Server正在监听的IP地址和端口号。
  使用上述方式配置网络并且启动GDB Server后，
  远程IP地址为 ``192.168.10.8``，端口为 ``1234``。所以，我们用于建立连接的命令如下：

  .. code-block:: shell

    (gdb) target extended-remote 192.168.10.8:1234
    Remote debugging using 192.168.10.8:1234
    (gdb)

  连接成功后，GDB会显示如上代码段的内容，表示当前正在通过 ``192.168.10.8:1234`` 远程调试。
  这表明TCP连接建立成功，之后可以在本地主机上对虚拟机中的代码进行调试。

  当然，我们也可以一步到位的启动GDB并连接到GDB Server，命令如下：

  .. code-block:: shell

    $ gdb -ex "target extended-remote 192.168.10.8:1234"
    GNU gdb (Ubuntu 12.1-0ubuntu1~22.04) 12.1
    Copyright (C) 2022 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    Type "show copying" and "show warranty" for details.
    This GDB was configured as "aarch64-linux-gnu".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <https://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
        <http://www.gnu.org/software/gdb/documentation/>.

    For help, type "help".
    Type "apropos word" to search for commands related to "word".
    Remote debugging using 192.168.10.8:1234
    (gdb) 

  .. note:: 

    GDB连接远程GDB Server有两种命令：
    ``target remote [ip]:[port]`` 和 ``target extended-remote [ip]:[port]``。
    如果只使用 ``target remote`` 命令，当远端没有待调试的程序时，
    GDB client会断开连接，GDB Server也会因而停止工作。
    由于我们启动GDB Server时没有具体指定需要debug的程序，
    如果在本地主机中使用 ``target remote`` 命令连接GDB Server，
    则远端的GDB Server会马上退出，它和本地主机GDB之间的TCP连接也会马上断开。
    ``target extended-remote`` 命令则可以避免这个问题，因为即使没有被调试的程序，
    GDB和GDB Server之间的连接依然会被保持。
    所以在本文的演示中，使用的是 ``target extended-remote`` 命令连接GDB Server。

5. 编译含有调试信息的可执行文件

  在编译的时候，需要加上 ``-g`` 这一标志，让编译器在编译的时候生成带有调试信息的可执行文件。
  如果没加上 ``-g`` 这一标志，我们仍然可以使用GDB对可执行文件进行编译，
  但是由于没有相应的调试信息，我们无法跟踪高级语言中的变量，
  而只能在汇编语言的层面对可执行文件进行调试。

  如果项目是以CMAKE为构建工具，可以在执行 ``cmake`` 命令时，
  加上 ``-DCMAKE_BUILD_TYPE=Debug`` 这一标志，或者在yocto构建工程的bb文件中，
  加上 ``EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Debug"`` 这一行，
  则最终编译的时候会自动加上 ``-g`` 这一标志。

