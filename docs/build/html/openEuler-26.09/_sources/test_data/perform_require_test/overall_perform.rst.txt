.. _overall_perform:

1.2 综合性能
#####################

1.2.1 测试目的
*************************************
分别基于OEE、OEE-RT 以及 OEE-RT + Jailhouse，评估系统在某些场景下的综合性能表现及差异。
例如CPU运算性能等。


1.2.2 CPU运算性能
*********************

测试工具
===============

-  sysbench

测试方案
===============

    开启若干线程，使用sysbench工具，在10s内对指定数量的线程进行循环10000素数运算获取CPU的计算性能。

    测试指令：

    .. code-block:: console

        taskset -c 2 sysbench cpu --threads=1 run


    指令在串口终端下执行。
    
测试结果
===============

    进行五轮测试，取五次平均值统计结果如下：

.. list-table:: 表1-1 CPU运算性能结果
    :align: center

    * - **测试工具**
      - **测试项**
      - **OEE**
      - **OEE-RT**
      - **OEE-RT+Jailhouse**
    * - sysbench cpu
      - 每秒可处理事件数
      - 894.68
      - 1010.634
      - 1009.278
    * - 
      - 事件最小处理时间(ms)
      - 1.02
      - 0.99
      - 0.99
    * - 
      - 事件平均处理时间(ms)
      - 1.11
      - 0.99
      - 0.99
    * - 
      - 事件最大处理时间(ms)
      - 17.08
      - 1.01
      - 1.006
    * - 
      - 95%事件处理时间(ms)
      - 1.07
      - 0.99
      - 0.99

测试结果分析
==============
1. 在每秒处理的事件数量上，OEE-RT比OEE性能提升10%以上。
2. 在事件最大处理时间上，OEE-RT从OEE的17.08ms提升到1.01ms，性能提升非常明显。
3. OEE-RT在添加Jailhouse虚拟化后，CPU性能几乎不受影响。

测试结论
==============
1. 在CPU运算性能方面，OEE-RT的性能全面优于OEE。
2. OEE-RT在添加Jailhouse后，对OEE-RT的性能几乎没有影响，各项指标性能相当。

1.2.3 IO性能
*********************

测试工具
===============

-  sysbench

测试方案
===============

    使用sysbench的fileio工具，创建测试数据（prepare）指定文件读写模式为rndrw（随机读写），在指定时间内完成的读写速率，最后清理数据（cleanup）

    测试指令：

    .. code-block:: console

        # 准备阶段：

        taskset -c 2 sysbench fileio --threads=1 --file-test-mode=rndrw --file-total-size=64M

        --file-num=16 --file-block-size=1M prepare

        # 运行阶段：

        taskset -c 2 sysbench fileio --threads=1 --file-test-mode=rndrw --file-total-size=64M

        --file-num=16 --file-block-size=1M run

    指令均在串口终端下执行。
   
测试结果
===============

    进行五轮测试，取五次平均值统计结果如下：

.. list-table:: 表1-10 IO读写测试结果
    :align: center

    * - **测试工具**
      - **测试项**
      - **OEE**
      - **OEE-RT**
      - **OEE-RT+Jailhouse**
    * - sysbench fileio
      - 随机读速度（MB/s）
      - 3.90
      - 119.9
      - 119.074
    * - 
      - 随机写速度（MB/s）
      - 2.59
      - 79.934
      - 79.39
    * - 
      - 最小读写时间(ms)
      - 0.89
      - 0.152
      - 0.138
    * - 
      - 平均读写时间(ms)
      - 113.08
      - 4.416
      - 4.458
    * - 
      - 最大读写时间(ms)
      - 1736.64
      - 63.916
      - 63.644
    * - 
      - 95%的读写时间(ms)
      - 885.28
      - 27.466
      - 27.562

测试结果分析
==============
1. 在随机读和随机写的速度上，OEE-RT分别达到了119.9MB/s和79.934MB/s，相比OEE的3.90MB/s和2.59MB/s,有了数量级级别的性能提升。
2. 在读写时间上，OEE-RT相对于OEE来说，也有很大的性能提升。比如在平均读写时间和最大读写时间上，OEE-RT相比OEE来说，也获得了数量级级别的性能提升。
3. OEE-RT在添加Jailhouse虚拟化后，不管是在读写速度上还是在读写时间上，性能影响几乎可以忽略不计。

测试结论
==============
1. 在IO性能测试的各项指标上，OEE-RT相比OEE，性能都获得了大幅提升。
2. OEE-RT在添加Jailhouse虚拟化后，IO性能几乎没有影响。

