基于UniProton的RPC服务
########################

RPC简介
---------

远程调用（Remote Procedure Call，简称RPC）是一种分布式计算中的通信方式，用于实现不同计算机之间的程序调用。它允许在一个计算机上运行的程序能够调用另一个计算机上的程序，就像调用本地程序一样简单。

当实时侧需要访问Linux侧的文件或者依靠Linux的网络协议栈与其他终端进行网络通信的时候，可以使用RPC服务。

基于UniProton的RPC服务基于mica混合部署框架，UniProton侧将用户的请求信息和接口进行封装，写入共享内存，并通过中断通知Linux。Linux侧收到消息后，进行请求信息解析和分发，找到对应的函数和方法，执行相应的逻辑。执行完成后，Linux将结果通过共享内存和中断的方式发送给UniProton。UniProton接收到Linux消息后，解析结果并进行相应的处理。

______________________________

基于UniProton的RPC服务使用方法
------------------------------

首先，需要构建含有MICA的openEuler Embedded镜像，请参考 :ref:`MICA镜像构建指南 <mcs_build>` 。

然后，需要在UniProton的build/uniproton_config/`*`/defconfig中开启CONFIG_OS_OPTION_PROXY选项开关即可使用RPC远程调用功能，UniProton构建请参考 `UniProton构建 <https://gitee.com/openeuler/UniProton/blob/master/doc/UniProton_build.md>`_ 。

最后，通过MICA混合部署拉起UniProton，请参考 :ref:`MICA使用指南 <mica_ctl>` 。

_______________________________

UniProton目前支持的RPC接口类型
-------------------------------
.. list-table::
   :widths: 15 60
   :header-rows: 1

   * - 类型
     - 具体接口
   * - 系统调用
     - open、read、write、close、poll、system、writev
   * - 文件
     - lseek、fcntl、unlink、fopen、fclose、fread、fwrite、freopen、fgets、fputs、feof
       fprintf、ferror、lseek、fcntl、unlink、tmpfile、clearerr、ungetc、getc、getc_unlocked
       fseeko、ftello、fseek、ftell、rename、remove、mkstemp、getwc、putwc、putc、fputc、
       ungetwc、fflush、stat、getcwd、vfprintf、lstat、fstat、fileno、fdopen、setvbuf、vprintf
       readlink、access、dup2、chmod、chdir、mkdir、rmdir、fscanf、putchar
   * - 网络
     - socket、bind、connect、listen、select、accept、recv、recvfrom、send、sendto
       setsockopt、getsockopt、gethostbyaddr、gethostbyname、getaddrinfo、freeaddrinfo
       getpeername、gethostname、getsockname、getsockopt、shutdown、if_nameindex、gai_strerror
       accept4
   * - 进程通信
     - popen、pclose、pipe、mkfifo
 
______________________

UniProton新增RPC接口
----------------------
如果上诉支持的接口无法满足要求，需要新增RPC接口，基于RPC服务的endpoint已经创建，名称为rpmsg-rpc，用户可参考如下进行修改

UniProton：参考文件src/component/proxy/rpc_routines.c，实现消息格式的封装。

Linux：参考文件mica/micad/services/rpc/rpc_backend.c，实现消息的解封装和处理。

.. note::

   当前Uniproton的RPC服务不支持标准输入，标准输出会重定向输出到文件中。

