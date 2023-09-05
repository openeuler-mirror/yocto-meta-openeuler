外设分区管理
############

总体介绍
========

受益于硬件技术的快速发展，先进封装技术带来了更高的集成度，一个片上系统(SoC)中能够封装各种丰富的外设组件，为部署混合关键性系统提供了坚实的物理基础，但同时也带来了一个挑战：Linux、RTOS或其他操作系统在运行时有各自的资源访问需求，需要能够直接访问 SoC 的不同部分，并排运行并且不会相互干扰。针对该场景，用户可以使用外设分区管理配置各OS需要的外设资源。

通过外设分区管理，能够在集成构建的过程中，根据用户的配置文件，对完整的设备树进行解析和操作，最终生成针对不同OS的设备树。

本章主要介绍如何基于yocto-meta-openeuler使用外设分区管理，以及如何编写自定义的配置文件。

____

如何使用外设分区管理
====================

1. 在对应的BSP层添加 ``lopper-ops.bbappend`` 和 ``lops`` 文件夹，用于承载用户的配置文件。例如：

   .. code-block:: console

      .
      └── meta-openeuler-bsp
          └── recipes-kernel
              └── lopper
                  ├── lopper-ops.bbappend
                  └── lops
                      └── lop-user-config.dts

   ``lopper-ops.bbappend`` 主要是将当前目录的lops文件夹传递给yocto，内容如下：

   .. code-block:: console

      $ cat lopper-ops.bbappend
      # Use the operation files from current layer
      FILESEXTRAPATHS:prepend := "${THISDIR}/:"

   ``lops`` 用于放置用户自定义的配置文件，这些配置文件统一用device-tree格式描述，但是有单独的语法，
   用于描述关于输入设备树的操作，包括：修改（删除）某个设备节点；添加自定义节点；提取部分节点并生成新的设备树等。
   具体如何编写 ``lop-user-config.dts`` ，请参考下一小节。

2. 在使用设备树文件的配方中（假设为 ``foo-A.bb``），调用 lopper-devicetree.bbclass ，并配置输入和输出，如：

   .. code-block:: shell

      # foo-A.bb
      inherit lopper-devicetree
      INPUT_DT = "${B}/input-sample.dtb"
      OUTPUT_DT = "${B}/output-sample.dtb"

   | **输入**：``input-sample.dtb``，完整的设备树。
   | **输出**：``output-sample.dtb``，处理后的设备树。此外，还会输出根据配置文件生成的RTOS侧设备树。
   | 即：

   .. code-block:: none

                                             ┌──────►  output-sample.dtb   -- for Linux
                                             │
                                             │
                         lop-user-config.dts │
      input-sample.dtb ──────────────────────┤
                                             │
                                             │
                                             │
                                             └──────►  serial-for-zephyr.dts -- for zephyr

   默认会通过 lopper-devicetree 中的 do_mkdts 完成设备树的处理，这个任务默认的依赖关系为
   ``before do_install after do_compile`` ，因此，用户可以在 ``do_install`` 中使用处理后的设备树 ``output-sample.dtb``。

   另外，用户可以通过配置文件生成RTOS侧的设备树，例如，指明提取某个 serial 节点，并生成
   ``serial-for-zephyr.dts`` ，经过处理后，这份 dts 默认会被安装到 ``foo-A`` 的 SYSROOT_DIR 中，
   因此，在其它的配方中（``foo-B.bb``）可以通过以下方法获取该 dts 文件：

   .. code-block:: shell

      # foo-B.bb

      # add dependence
      DEPENDS += "foo-A"

      # get the serial-for-zephyr.dts
      do_configure:append() {
          cp ${WORKDIR}/recipe-sysroot/lop_dts/serial-for-zephyr.dts ${B}/
      }

.. seealso::

   yocto-meta-openeuler 中为树莓派添加了一个使用案例，将 ``serial@7e201a00`` 提取给zephyr使用，
   参考提交 `rpi4: extract a serial for zephyr <https://gitee.com/openeuler/yocto-meta-openeuler/commit/144641062>`_。

____

如何编写外设分区配置文件
========================

外设分区管理是基于开源工具 lopper 完成的，用户可以自定义配置文件（lopper operations），以实现设备树节点的修改、删除、提取等操作。
关于 lopper operations 详细完整的语法配置，可以阅读学习 `lopper/README-architecture <https://github.com/devicetree-org/lopper/blob/master/README-architecture.md>`_。
下面，会介绍一些较为常用的功能接口。

**lopper operations 的格式**：

   lopper operations(lops) 的结构类似于标准的dts文件，设备树的根必须指定 ``compatible = "system-device-tree-v1,lop";``，以便识别为 lop 文件。
   所有的操作都需要定义在 ``lops/lop_<number>`` 中（number仅用于标识，lop的解析顺序是其出现在文件中的顺序）。

   .. code-block:: none

      /dts-v1/;

      / {
              compatible = "system-device-tree-v1";
              lops {
                      lop_<number> {
                              compatible = "system-device-tree-v1,lop,<lop type>";   // compatible 注明 lop 的类型
                              <lop specific properties>;
                      };
                      lop_<number> {
                              compatible = "system-device-tree-v1,lop,<lop type>";
                              <lop specific properties>;
                      };
              };
      };

不同类型的 lop 有各自的 compatible 和 properties，包括：

1. **modify**

   用于修改指定路径的设备节点，包括修改property、添加property、删除或移动设备节点。

   对应的 compatible 为：``"system-device-tree-v1,lop,modify"``

   对应的 property 格式为：``modify = "<path to node>:<property>:<replacement>"``

   具体用法可参考：

   .. code-block:: shell

      // 重命名 /cpus_r5 节点为 /cpus
      lop_1 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/cpus_r5/::/cpus/";
      };

      // 删除 /cpus_r5 节点
      lop_2 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/cpus_r5/::";
      };

      // 移动 /cpus_r5 节点到 /soc/cpus_r5
      lop_3 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/cpus_r5::/soc/cpus_r5";
      };

      // 将 memory@800000000 中的 reg 修改为 modify_val 中的 reg
      lop_4 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/memory@800000000:reg:&modify_val#reg";
            modify_val {
                reg = <0x0 0x00000000 0x0 0x200000>;
            };
      };

      // 为 /soc/serial@7e201000 节点添加 my-prop = okay
      lop_5 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/soc/serial@7e201000:my-prop:okay";
      };

      // 修改 /soc/serial@7e201000 的 my-prop 为 disable
      lop_6 {
            compatible = "system-device-tree-v1,lop,modify";
            modify = "/soc/serial@7e201000:my-prop:disable";
      };

2. **node add**

   添加节点，例如，添加 ``mcs@70000000`` 到 /reserved-memory/ 中：

   .. code-block:: shell

      lop_1 {
            compatible = "system-device-tree-v1,lop,add";
            node_src = "mcs@70000000";
            node_dest = "/reserved-memory/";
            mcs@70000000 {
                reg = <0x00 0x70000000 0x00 0x10000000>;
                compatible = "mcs_mem";
                no-map;
            };
      };

3. **output**

   将指定的 nodes 输出到 output 中（源文件不会被修改），output 可以指定为 dts 也可以指定为 dtb，而且 nodes 支持正则匹配。

   .. code-block:: shell

      // 将 "reserved-memory", "cpu1", "ipi1" 节点输出到 test.dtb
      lop_1 {
            compatible = "system-device-tree-v1,lop,output";
            outfile = "test.dtb";
            nodes = "reserved-memory", "cpu1", "ipi1";
      };

      // 所有的节点都输出到 test.dtb
      lop_2 {
            compatible = "system-device-tree-v1,lop,output";
            outfile = "test.dtb";
            // * is "all nodes"
            nodes = "*";
      };

      // 所有 testprop 为 testvalue 的 axi 节点都输出到 test.dts
      lop_3 {
            compatible = "system-device-tree-v1,lop,output";
            outfile = "test.dts";
            nodes = "axi.*:testprop:testvalue";
      };

4. **select**

   select lop 通常用于选择一个满足 select_* 的节点。可以同时有多条 select 语句，并且这些 select 是全局的，在 lop_1 定义的 select，可以沿用到 lop_2 中。

   select 的语法跟 modify 操作的语法相同：``select_* = "<path to node>:<property>:<value>"``

   示例一：选择满足 select_1 或满足 select_2 的节点，类似于 ``if (node1 || node2)`` ：

   .. code-block:: shell

      // for node1
      select_1 = "/path/or/regex/to/nodes:prop:val";

      // for node2
      select_2 = "/path/or/2nd/node/regex:prop2:val2";

   示例二：选择同时满足 select_1 和 select_2 的节点，类似于 ``if (node1.prop1.val1 && node1.prop2.val2)`` ：

   .. code-block:: shell

      // for node1.prop1.val1
      select_1 = "/path/or/regex/to/nodes:prop1:val1";

      // for node1.prop2.val2
      select_2 = ":prop2:val2";

   由于 select 是全局的，因此用法十分灵活，也略微复杂，一些用法示例：

   .. code-block:: shell

      lop_1 {
            compatible = "system-device-tree-v1,lop,select-v1";
            // 清除前面选择的节点
            select_1;
            // 选择 compatible 为 ".*arm,cortex-a72.*"，并且 cpu-idle-states 为 3 的 cpu 节点
            select_2 = "/cpus/.*:compatible:.*arm,cortex-a72.*";
            select_3 = ":cpu-idle-states:3";
      };

      lop_2 {
            // modify 的 path 是空，所以对之前 select 的节点进行 modify 操作
            compatible = "system-device-tree-v1,lop,modify";
            modify = ":testprop:testvalue";
      };

      lop_4 {
            compatible = "system-device-tree-v1,lop,select-v1";
            // 清空之前的select
            select_1;
            // 选择 compatible 为 ".*arm,cortex-a72.*" 的 cpu 节点
            // 或 phy-handle 为 0x9 的 axi 节点
            select_2 = "/cpus/.*:compatible:.*arm,cortex-a72.*";
            select_3 = "/axi/.*:phy-handle:0x9";
      };

5. **cond**

   可以在任意的 lop 中使用 cond 指定一个 select lop，并进行条件判断，若 select lop 为真，则 lop 会继续解析并执行；若 select lop 为假，则 lop 会被忽略。

   .. code-block:: shell

      lops {
            // 定义一个 select lop，
            // 判断 device-tree 的 compatible 是否为 "raspberrypi,4-model-b\0brcm,bcm2711"
            lop_1: lop_1 {
                compatible = "system-device-tree-v1,lop,select-v1";
                select_1;
                select_2 = "/:compatible:raspberrypi,4-model-b\0brcm,bcm2711";
            };

            // 通过 cond 进行条件判断
            // 若 select 为真，则进行 modify 操作，删除 /soc/serial@7e201a00/ 节点
            lop_1_1: lop_1_1 {
                lop_1_1_1 {
                        compatible = "system-device-tree-v1,lop,modify";
                        cond = <&lop_1>;
                        modify = "/soc/serial@7e201a00/::";
                };
            };
      };

6. **tree**

   可以通过 tree 指定一个 node 集，并且对该 node 集进行 modify，output 等操作。

   modify 等 lop，默认会对输入的设备树文件进行操作，如果指定了 tree 就会在对应的 node 集中进行操作，如：

   .. code-block:: shell

      // 创建一棵 tree(test-tree)，包含 nodes 中指定的节点
      lop_1 {
            compatible = "system-device-tree-v1,lop,tree";
            tree = "test-tree";
            nodes = "reserved-memory", "cpu1", "ipi1";
            nodes = "reserved-memory", "zynqmp-rpu", "zynqmp_ipi1";
      };

      // 针对 test-tree 做 modify
      lop_2 {
            compatible = "system-device-tree-v1,lop,modify";
            tree = "test-tree";
            modify = "/reserved-memory:#size-cells:3";
      };

      // 针对 test-tree 进行 output 操作，输出 nodes 中指定的节点
      lop_3 {
            compatible = "system-device-tree-v1,lop,output";
            tree = "test-tree";
            outfile = "output.dts";
            nodes = "reserved-memory";
      };

7. **print**

   print lop 可以用于增加调试打印，任何以 print 开头的property在被处理时，都会输出到 stdout。

   .. code-block:: shell

      lop_1 {
            compatible = "system-device-tree-v1,lop,print-v1";
            print = "print_test: print 1";
            print2 = "print_test: print2";
      };

.. note::

   应用示例： `rpi4: extract a serial for zephyr <https://gitee.com/openeuler/yocto-meta-openeuler/commit/144641062>`_

   除本文介绍的接口外，lopper 还支持一些其它的 lops，比如 conditional, exec, code 等，还支持通过 assists 加载自定义的 python 代码进行 dts 的解析处理。

   更多用法探索，请阅读学习 `lopper/README-architecture <https://github.com/devicetree-org/lopper/blob/master/README-architecture.md>`_。

