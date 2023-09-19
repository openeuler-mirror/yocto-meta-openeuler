.. _musl_libc:

musl libc的支持
################################

本章介绍使用musl libc构建openEuler Embedded。

musl libc的介绍
----------------------------------------

musl libc是构建在Linux系统调用API之上的C标准库的实现，是一个轻量级libc库，用于嵌入式操作系统和移动设备。它包括在基本语言标准、POSIX和广泛认可的扩展中定义的接口。

meta-musl层介绍
----------------------------------------

``meta-musl`` 层包含所有涉及musl libc的软件包的补丁，该层以叠加 ``*.bbappend`` 的形式，把musl libc相关修改到对应软件包上。对于后续软件包的适配可直接在meta-musl层中进行修改，更加利于后期管理和维护。

``meta-musl`` 层目录结构如下

.. code-block:: console

    tree -L 3  .
    .
    ├── conf
    │   └── layer.conf
    ├── recipes-connectivity
    │   ├── iproute2
    │   │   ├── iproute2
    │   │   └── iproute2_%.bbappend
    ├── recipes-core
    │   ├── dsoftbus
    │   │   ├── dsoftbus
    │   │   └── dsoftbus_%.bbappend
    ├── ......
    ├── ......
    └── ......

构建环境
----------------------------------------

构建环境推荐：master

构建环境指导：详见 :ref:`openeuler_embedded_oebuild`

编译器构建指导：musl交叉工具链的生成可 `参考编译器构建指导 <https://gitee.com/openeuler/yocto-embedded-tools/tree/master/cross_tools>`_

特定环境配置：由于poky升级到4.0.x后，meson的编译规则改变，会导致一些包产生中间产物--检查交叉编译环境配置的可执行程序，但是目前docker中没有musl的链接器：ld-musl-aarch64.so.1，所以需要执行下边命令把musl的链接器拷贝到docker中：

.. code-block:: console

   sudo docker cp /path/aarch64-openeuler-linux-musl/xx/ld-musl-aarch64.so.1  dockerid:/usr/lib64

.. attention::

   ld-musl-aarch64.so.1要修改成实体的，不要拷贝软连接！

qemu镜像的构建
----------------------------------------
1.构建环境示例
  
参考 :ref:`openeuler_embedded_oebuild` 初始化容器环境，生成配置文件时使用如下命令：

.. code-block:: console

   oebuild generate -p qemu-aarch64 -t /path/to/aarch64-openeuler-linux-musl -f musl

.. attention::

   当前在容器里是没有musl-arm64的工具链，需要按照上面工具链的生成指导生成。

2.构建命令

键入 ``oebuild bitbake`` 进入容器环境后，执行下面命令即可编译镜像：

.. code-block:: console

   bitbake openeuler-image

3.构建镜像生成目录示例

结果件默认生成在构建目录下的output目录下：

.. code-block:: console

        /usr1/build/ouput

镜像运行 `QEMU参考运行指导 <https://openeuler.gitee.io/yocto-meta-openeuler/master/getting_started/index.html#id4>`_


树莓派镜像的构建
----------------------------------------
1.构建命令示例

.. code-block:: console

   oebuild generate -p raspberrypi4-64 -t /path/to/aarch64-openeuler-linux-musl -f musl

   oebuild bitbake 

   bitbake openeuler-image

2.构建镜像生成目录

结果件默认生成在构建目录下的output目录下：

.. code-block:: console

        /usr1/build/ouput 

镜像运行 `树莓派参考运行指导 <https://openeuler.gitee.io/yocto-meta-openeuler/master/features/raspberrypi.html>`_

clang+llvm构建镜像
----------------------------------------

1. 构建环境

   .. attention::

      当前在容器中没有集成musl相关的工具链，所以需要先把基于musl编译的arm64架构GCC库拷贝至编译器目录：

   .. code-block:: console

      sudo cp /path/to/aarch64-openeuler-linux-musl/* /path/to/clang-llvm-15.0.3

   参考 :ref:`openeuler_embedded_oebuild` 初始化容器环境，生成配置文件时使用如下命令：

   .. code-block:: console

      oebuild generate -p platform -d build_direction -t /path/to/clang-llvm-15.0.3 -f clang -f musl

   .. attention::

      当前只支持arm64架构，支持的平台：qemu-aarch64、raspberrypi4-64。

2. 构建命令

   .. code-block:: console

      bitbake openeuler-image-llvm

3. SDK生成

   .. code-block:: console

      bitbake openeuler-image-llvm -c populate_sdk

musl与glibc性能对比测试
----------------------------------------
性能测试平台采用了主频为600Mhz的树莓派4B，测试集采用了libc-bench、coremark、lmbench、unixbench，以下为测试集简介：

==================== ===============================================================================================
测试集                             简介
==================== ===============================================================================================
libc-bench                 musl 官方提供的测试集，用于时间和内存效率的测试，该测试集中比较了各种C/POSIX标准库函数的实现。
coremark                   CoreMark是由EEMBC提出的基准测试程序， 是评测嵌入式芯片性能的最常用测试程序之一。
lmbench                    lmbench 是个用于评价系统综合性能的多平台开源 benchmark，能够测试包括文档读写、 内存操作、进程创建销毁开销、网络等性能。
unixbench                  unixbench是一个用于测试unix系统性能的工具。
==================== ===============================================================================================

libc-bench性能测试
----------------------------------------
1.执行时间测试

============================= ==================== ==================== ====================
测试项                          glibc执行时间(s)     musl执行时间(s)          性能比
============================= ==================== ==================== ====================
b_malloc_sparse          	  0.133191926	     0.155694333	-14%
b_malloc_bubble	                  0.132751351	     0.160789685	-17%
b_malloc_tiny1	                  0.004129741	     0.006242797	-34%
b_malloc_tiny2	                  0.003741592	     0.004415814	-15%
b_malloc_big1	                  0.030093408	     0.085103333	-65%
b_malloc_big2	                  0.026437222	     0.059723722	-56%
b_malloc_thread_stress	          0.057703185	     0.191215629	-70%
b_malloc_thread_local	          0.040528055	     0.1589995	        -75%
b_string_strstr(abcd)	          0.022583204	     0.033620482	-33%
b_string_strstr(azby)	          0.022762333	     0.052186926	-56%
b_string_strstr(ac)	          0.023064741	     0.034024092	-32%
b_string_strstr(aaac)	          0.02253924	     0.034291277	-34%
b_string_strstr(aaaaac)	          0.024667129	     0.038916833	-37%
b_string_memset	                  0.021160371	     0.016245278	30%
b_string_strchr	                  0.028452092	     0.044776333	-36%
b_string_strlen	                  0.01696987	     0.025606074	-34%
b_pthread_createjoin_serial1	  0.546294574	     0.589207315	-7%
b_pthread_createjoin_serial2	  0.518631648	     0.443272055	17%
b_pthread_create_serial1	  0.452602518	     0.405491611	12%
b_pthread_uselesslock	          0.167918796	     0.151241092	11%
b_stdio_putcgetc	          0.269504648	     0.296806204	-9%
b_pthread_createjoin_minimal1	  0.526583	     0.565946184	-7%
b_pthread_createjoin_minimal2	  0.455035314	     0.490921982	-7%
============================= ==================== ==================== ====================

**备注** ：性能比由 ``glibc执行时间/musl执行时间-1`` 计算得到。

2.内存占用测试

- 虚拟内存占用测试

============================= =================================== =================================== =====================================
测试项	                                    glibc(KB)			        musl(KB)		        glibc_virt/musl_virt		
============================= =================================== =================================== =====================================
b_malloc_sparse	                             38992	                        8480	                             4.60
b_malloc_bubble	                             39364	                        156	                             252.33
b_malloc_tiny1	                             688	                        32	                             21.50
b_malloc_tiny2	                             688	                        628	                             1.10
b_malloc_big1	                             160	                        24	                             6.67
b_malloc_big2	                             80192	                        87404	                             0.92
b_malloc_thread_stress	                     16808	                        52	                             323.23
b_malloc_thread_local	                     16808	                        80	                             210.10
b_string_strstr(abc)	                     160	                        16	                             10.00
b_string_strstr(azby)	                     160	                        16	                             10.00
b_string_strstr(ac)	                     160	                        16	                             10.00
b_string_strstr(aaac)	                     160	                        16	                             10.00
b_string_strstr(aaaaac)	                     160	                        16	                             10.00
b_string_memset	                             160	                        16	                             10.00
b_string_strchr	                             160	                        16	                             10.00
b_string_strlen	                             160	                        16	                             10.00
b_pthread_createjoin_serial1	             8352	                        16	                             522.00
b_pthread_createjoin_serial2	             32928	                        16	                             2058.00
b_pthread_create_serial1	             20480820	                        50016	                             409.49
b_pthread_uselesslock	                     8352	                        16	                             522.00
b_stdio_putcgetc	                     160	                        16	                             10.00
b_stdio_putcgetc_unlocked	             160	                        16	                             10.00
b_regex_compile	                             160	                        40	                             4.00
b_regex_search	                             160	                        16	                             10.00
b_regex_search	                             160	                        16	                             10.00
b_pthread_createjoin_minimal1	             8352	                        16	                             522.00
b_pthread_createjoin_minimal2	             41120	                        16	                             2570.00
============================= =================================== =================================== =====================================

- 物理内存占用测试

============================= =================================== =================================== =====================================
测试项                                      glibc(KB)                           musl(KB)                            glibc_res/musl_res
============================= =================================== =================================== =====================================
b_malloc_sparse	                             38980	                        8480	                             4.60
b_malloc_bubble	                             39240	                        92	                             426.52
b_malloc_tiny1	                             568	                        32	                             17.75
b_malloc_tiny2	                             568	                        604	                             0.94
b_malloc_big1	                             32	                                24	                             1.33
b_malloc_big2	                             8044	                        16072	                             0.50
b_malloc_thread_stress	                     164	                        52	                             3.15
b_malloc_thread_local	                     184	                        80	                             2.30
b_string_strstr(abc)	                     20	                                16	                             1.25
b_string_strstr(azby)	                     20	                                16	                             1.25
b_string_strstr(ac)	                     20	                                16	                             1.25
b_string_strstr(aaac)	                     20	                                16	                             1.25
b_string_strstr(aaaaac)	                     20	                                16	                             1.25
b_string_memset	                             20	                                16	                             1.25
b_string_strchr	                             20	                                16	                             1.25
b_string_strlen	                             20	                                16	                             1.25
b_pthread_createjoin_serial1	             28	                                16	                             1.75
b_pthread_createjoin_serial2	             68	                                16	                             4.25
b_pthread_create_serial1	             20724	                        10016	                             2.07
b_pthread_uselesslock	                     28	                                16	                             1.75
b_stdio_putcgetc	                     24	                                16	                             1.50
b_stdio_putcgetc_unlocked	             24	                                16	                             1.50
b_regex_compile	                             32	                                28	                             1.14
b_regex_search	                             32	                                16	                             2.00
b_regex_search	                             84	                                16	                             5.25
b_pthread_createjoin_minimal1	             28	                                16	                             1.75
b_pthread_createjoin_minimal2	             76	                                16	                             4.75
============================= =================================== =================================== =====================================

- 系统可回收内存测试

============================= =================================== =================================== =====================================
测试项                                      glibc(KB)                          musl(KB)                      glibc_dirty/musl_dirty
============================= =================================== =================================== =====================================
b_malloc_sparse	                             38976	                        8480	                             4.60
b_malloc_bubble	                             39236	                        92	                             426.48
b_malloc_tiny1	                             564	                        32	                             17.63
b_malloc_tiny2	                             564	                        604	                             0.93
b_malloc_big1	                             28	                                24	                             1.17
b_malloc_big2	                             8040	                        13052	                             0.62
b_malloc_thread_stress	                     160	                        52	                             3.08
b_malloc_thread_local	                     180	                        80	                             2.25
b_string_strstr(abc)	                     16	                                16	                             1.00
b_string_strstr(azby)	                     16	                                16	                             1.00
b_string_strstr(ac)	                     16	                                16	                             1.00
b_string_strstr(aaac)	                     16	                                16	                             1.00
b_string_strstr(aaaaac)	                     16	                                16	                             1.00
b_string_memset	                             16	                                16	                             1.00
b_string_strchr	                             16	                                16	                             1.00
b_string_strlen	                             16	                                16	                             1.00
b_pthread_createjoin_serial1	             24	                                16	                             1.50
b_pthread_createjoin_serial2	             64	                                16	                             4.00
b_pthread_create_serial1	             20720	                        10016	                             2.07
b_pthread_uselesslock	                     24	                                16	                             1.50
b_stdio_putcgetc	                     20	                                16	                             1.25
b_stdio_putcgetc_unlocked	             20	                                16	                             1.25
b_regex_compile	                             28	                                28	                             1.00
b_regex_search	                             28	                                16	                             1.75
b_regex_search	                             80	                                16	                             5.00
b_pthread_createjoin_minimal1	             24	                                16	                             1.50
b_pthread_createjoin_minimal2	             72	                                16	                             4.50
============================= =================================== =================================== =====================================

coremark性能测试
----------------------------------------
1.单线程测试

- glibc测试结果

.. code-block:: console

   2K performance run parameters for coremark.
   CoreMark Size    : 666
   Total ticks      : 12256
   Total time (secs): 12.256000
   Iterations/Sec   : 3263.707572
   Iterations       : 40000
   Compiler version : GCC10.3.1
   Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
   Memory location  : Please put data memory location here
                 (e.g. code in flash, data on heap etc)
   seedcrc          : 0xe9f5
   [0]crclist       : 0xe714
   [0]crcmatrix     : 0x1fd7
   [0]crcstate      : 0x8e3a
   [0]crcfinal      : 0x25b5
   Correct operation validated. See README.md for run and reporting rules.
   CoreMark 1.0 : 3263.707572 / GCC10.3.1 -O2 -DPERFORMANCE_RUN=1  -lrt / Heap

- musl测试结果

.. code-block:: console

   2K performance run parameters for coremark.
   CoreMark Size    : 666
   Total ticks      : 12333
   Total time (secs): 12.333000
   Iterations/Sec   : 3243.330901
   Iterations       : 40000
   Compiler version : GCC10.3.1
   Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
   Memory location  : Please put data memory location here
                 (e.g. code in flash, data on heap etc)
   seedcrc          : 0xe9f5
   [0]crclist       : 0xe714
   [0]crcmatrix     : 0x1fd7
   [0]crcstate      : 0x8e3a
   [0]crcfinal      : 0x25b5
   Correct operation validated. See README.md for run and reporting rules.
   CoreMark 1.0 : 3243.330901 / GCC10.3.1 -O2 -DPERFORMANCE_RUN=1  -lrt / Heap

综上，得到glibc得分为 ``5.45 Coremark/Mhz`` ，musl得分为 ``5.41 Coremark/Mhz`` 。


2.多线程测试

- glibc测试结果

.. code-block:: console

   2K performance run parameters for coremark.
   CoreMark Size    : 666
   Total ticks      : 12284
   Total time (secs): 12.284000
   Iterations/Sec   : 13025.073266
   Iterations       : 160000
   Compiler version : GCC10.3.1
   Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -DPERFORMANCE_RUN=1  -lrt
   Parallel PThreads : 4
   Memory location  : Please put data memory location here
                 (e.g. code in flash, data on heap etc)
   seedcrc          : 0xe9f5
   [0]crclist       : 0xe714
   [1]crclist       : 0xe714
   [2]crclist       : 0xe714
   [3]crclist       : 0xe714
   [0]crcmatrix     : 0x1fd7
   [1]crcmatrix     : 0x1fd7
   [2]crcmatrix     : 0x1fd7
   [3]crcmatrix     : 0x1fd7
   [0]crcstate      : 0x8e3a
   [1]crcstate      : 0x8e3a
   [2]crcstate      : 0x8e3a
   [3]crcstate      : 0x8e3a
   [0]crcfinal      : 0x25b5
   [1]crcfinal      : 0x25b5
   [2]crcfinal      : 0x25b5
   [3]crcfinal      : 0x25b5
   Correct operation validated. See README.md for run and reporting rules.
   CoreMark 1.0 : 13025.073266 / GCC10.3.1 -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -DPERFORMANCE_RUN=1  -lrt / Heap / 4:PThreads

- musl测试结果

.. code-block:: console

   2K performance run parameters for coremark.
   CoreMark Size    : 666
   Total ticks      : 12281
   Total time (secs): 12.281000
   Iterations/Sec   : 13028.255028
   Iterations       : 160000
   Compiler version : GCC10.3.1
   Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -DPERFORMANCE_RUN=1  -lrt
   Parallel PThreads : 4
   Memory location  : Please put data memory location here
                 (e.g. code in flash, data on heap etc)
   seedcrc          : 0xe9f5
   [0]crclist       : 0xe714
   [1]crclist       : 0xe714
   [2]crclist       : 0xe714
   [3]crclist       : 0xe714
   [0]crcmatrix     : 0x1fd7
   [1]crcmatrix     : 0x1fd7
   [2]crcmatrix     : 0x1fd7
   [3]crcmatrix     : 0x1fd7
   [0]crcstate      : 0x8e3a
   [1]crcstate      : 0x8e3a
   [2]crcstate      : 0x8e3a
   [3]crcstate      : 0x8e3a
   [0]crcfinal      : 0x25b5
   [1]crcfinal      : 0x25b5
   [2]crcfinal      : 0x25b5
   [3]crcfinal      : 0x25b5
   Correct operation validated. See README.md for run and reporting rules.
   CoreMark 1.0 : 13028.255028 / GCC10.3.1 -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -DPERFORMANCE_RUN=1  -lrt / Heap / 4:PThreads

综上，得到glibc得分为 ``21.74 Coremark/Mhz`` ，musl得分为 ``21.75 Coremark/Mhz`` 。

lmbench OS性能测试
----------------------------------------
1.处理器进程操作时间(微秒)

============= =============== ================ ==============
测试项           glibc            musl            性能差异
============= =============== ================ ==============
null call	4.19     	4.36    	-3.90%
null I/O	4.43     	4.48    	-1.12%
stat	        12.8	        13.1         	-2.29%
open clos	29.6     	29.3    	1.02%
slct TCP	19.3     	19.4    	-0.52%
sig inst	6.2             6.6             -6.06%
sig hndl	24.8     	24.4    	1.64%
fork proc	645             488             32.17%
exec proc	765             580             31.90%
sh proc	        4899	        2212         	121.47%
============= =============== ================ ==============

2.上下文切换时间(微秒)

============= =============== ================ ==============
测试项           glibc            musl            性能差异
============= =============== ================ ==============
2p/0K ctxsw	24.9	          23.3	          6.87%
2p/16K ctxsw	23.8	          24.2	         -1.65%
2p/64K ctxsw	24.2	          20.7	         16.91%
8p/16K ctxsw	28.3	          24.3	         16.46%
8p/64K ctxsw	27.6	          26.6	          3.76%
16p/16K ctxsw	28.2	          26.6	          6.02%
16p/64K ctxsw	37.9	          36	          5.28%
============= =============== ================ ==============

3.本地管道通信延迟(微秒)

============= =============== ================ ==============
测试项           glibc            musl            性能差异
============= =============== ================ ==============
Pipe	         84.3	          81.2	           3.82%
AF UNIX	         81.9	          71.7	          14.23%
UDP	        144.6	         133.7	           8.15%
TCP	        199.1	         196.1	           1.53%
TCP conn	556	         556	           0.00%
============= =============== ================ ==============

4.文件延迟(微秒)

=============== =============== ================ ==============
测试项           glibc            musl            性能差异
=============== =============== ================ ==============
0K File Create	52.4	          52.6	          -0.38%
0K File Delete	37.1	          37.5	          -1.07%
10K File Create	106.5	         104.1	           2.31%
10K File Delete	59.8	          60.7	          -1.48%
Mmap Latency	21.8K	          21.8K	           0.00%
Prot Fault	3.325	           3.342	  -0.51%
Page Fault	1.7151	           1.7067	   0.49%
100fd selct	10.5	          10.6	          -0.94%
=============== =============== ================ ==============

5.本地通信带宽(MB/s)

=============== =============== ================ ==============
测试项           glibc            musl            性能差异
=============== =============== ================ ==============
Pipe	          303	          306	           0.99%
AF UNIX	          592	          746	          26.01%
TCP	          373	          425	          13.94%
File reread	 1028.7	         1020.9	          -0.76%
Mmap reread	 2837.4	         2837.6	           0.01%
Bcopy (libc)	 1637.4	         1639.8	           0.15%
Bcopy(hand)	 1613	         1635.1	           1.37%
Mem read	 2128	         2124	          -0.19%
Mem write	 1681	         1680	          -0.06%
=============== =============== ================ ==============

unixbench性能测试
----------------------------------------
====================================== =============== ================ ============== ================= =================
测试项                                      musl           glibc          基准线         musl对比基准线   glibc对比基准线
====================================== =============== ================ ============== ================= =================
Dhrystone 2 using register variables	4981154.2 lps	6244531.8 lps	 116700.0 lps	  426.8	                535.1
Double-Precision Whetstone		1059.1 MWIPS	1062.0 MWIPS	 55.0 MWIPS	  192.6	         	193.1
Execl Throughput			1215.8 lps	653.9 lps	 43.0 lps	  282.7	         	152.1
File Copy 1024 bufsize 2000 maxblocks	62370.8 KBps	59823.5 KBps	 3960.0 KBps	  157.5	         	151.1
File Copy 256 bufsize 500 maxblocks 	17242.5 KBps	16201.4 KBps	 1655.0 KBps	  104.2	         	97.9
File Copy 4096 bufsize 8000 maxblocks	195350.9 KBps	191638.2 KBps	 5800.0 KBps	  336.8	         	330.4
Pipe Throughput			        58289.1 lps	58878.8 lps	 12440.0 lps	  46.9	         	47.3
Pipe-based Context Switching		12190.6 lps	12742.8 lps	 4000.0 lps	  30.5	         	31.9
Process Creation			1596.9 lps	1209.4 lps	 126.0 lps        126.7	         	96
Shell Scripts (1 concurrent)		1894.0 lpm	1516.3 lpm	 42.4 lpm	  446.7	         	357.6
Shell Scripts (8 concurrent)		594.4 lpm	478.0 lpm	 6.0 lpm          990.6	         	796.7
System Call Overhead			46124.2 lps	46279.8 lps	 15000.0 lpm	  30.7	         	30.9
====================================== =============== ================ ============== ================= =================

综上，基于glibc的树莓派系统跑分结果为 ``146.5`` ，基于muslc的树莓派系统跑分结果为 ``161.6`` 。
